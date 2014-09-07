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
#import "AppDelegate.h"
#import "LocalComicSingleton.h"

@interface BookmarkTableViewController ()
@property NSMutableArray *bookmarks;
@property BookmarkUtil *bookmarkUtil;
@end

@implementation BookmarkTableViewController
@synthesize bookmarks;
@synthesize bookmarkUtil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    bookmarks = [NSMutableArray new];
    bookmarkUtil = [BookmarkUtil getInstance];
    [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, self.tabBarController.tabBar.frame.size.height, 0)];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [bookmarks removeAllObjects];
    [bookmarkUtil restoreBookmarks];
    NSArray *bookmarkedComics = [bookmarkUtil bookmarkedComics];
    if (bookmarkedComics.count > 0) {
        [bookmarks addObjectsFromArray:bookmarkedComics];
    }
    bookmarks = [NSMutableArray arrayWithArray:[bookmarks reverseObjectEnumerator].allObjects];
    [self.tableView reloadData];
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
        UIImageView *coverImageView = (UIImageView*) [cell viewWithTag:1];
        UILabel *titleLabel = (UILabel*) [cell viewWithTag:2];
        UILabel *descriptionLabel = (UILabel*) [cell viewWithTag:3];
        UIImage *image = comic.cover;
        coverImageView.image = image;
        titleLabel.text = comic.name;
        descriptionLabel.text = [NSString stringWithFormat:@"Bookmark at page %ld", (long) ([bookmarkUtil bookmarkForComic:comic ] + 1)];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Comic *comic = [bookmarks objectAtIndex:indexPath.row];
    NSNumber *page = [NSNumber numberWithInteger:[bookmarkUtil bookmarkForComic:comic]];
    NSDictionary *userInfo = @{SELECTED_COMIC_KEY: comic, SELECTED_PAGE_KEY: page};
    [[NSNotificationCenter defaultCenter] postNotificationName:COMIC_SELECTED_NOTIFICATION object:nil userInfo:userInfo];
}

@end
