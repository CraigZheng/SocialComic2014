//
//  BookmarkTableViewController.m
//  SocialComic2014
//
//  Created by Craig Zheng on 1/09/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "BookmarkTableViewController.h"
#import "Comic.h"
#import "BookmarkUtil.h"
#import "LocalComicSingleton.h"

@interface BookmarkTableViewController ()
@property NSMutableArray *bookmarks;
@end

@implementation BookmarkTableViewController
@synthesize bookmarks;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"bookmark_cell_identifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell) {
        Comic *comic = [bookmarks objectAtIndex:indexPath.row];
        
    }
    return cell;
}
 
@end
