/*
 * Nescaline
 * Copyright (c) 2007, Jonathan A. Zdziarski
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 2
 * of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */

#import "SavedGameViewController.h"

@implementation SavedGameViewController
@synthesize delegate;

- (id)init
{
    self = [super init];

    if (self != nil) {
        UIImage *tabBarImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"History" ofType:@"png"]];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Saved Games" image:tabBarImage tag:0];
        [self reloadData];
    }

    return self;
}

- (void)loadView
{
    [super loadView];

    self.tableView.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)reloadData
{
    NSDirectoryEnumerator *dirEnum;
    NSString *file;

    fileList = [[NSMutableArray alloc] init];
    dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:ROM_PATH];

    while ((file = [dirEnum nextObject])) {
        NSString *ext = [file pathExtension];

        if ([[ext lowercaseString] isEqualToString:@"sav"]) {
            [fileList addObject:file];
        }
    }

    [self.tableView reloadData];
}

/* UITableViewControllerDelegate Methods */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fileList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = fileList[[indexPath indexAtPosition:1]];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [CellIdentifier stringByReplacingOccurrencesOfString:@".nes.sav" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [CellIdentifier length]) ];
        cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"History" ofType:@"png"]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", ROM_PATH, cell.reuseIdentifier];

    if ([delegate respondsToSelector:@selector(didSelectGameROMAtPath:)]) {
        [self.delegate didSelectGameROMAtPath:path];
    }
}

- (void)     tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /* Delete cell from data source */

        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

        for (int i = 0; i < [fileList count]; i++) {
            if ([cell.reuseIdentifier isEqualToString:fileList[i]]) {
                [fileList removeObjectAtIndex:i];
                break;
            }
        }

        /* Delete cell from table */
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:indexPath];
        [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];

        /* Delete saved game */
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", ROM_PATH, cell.reuseIdentifier]
                                                      error:&error
       ];
    }
}

@end
