//
//  DownloadManagerTableViewController.m
//  SocialComic2014
//
//  Created by Craig on 11/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "DownloadManagerTableViewController.h"
#import "ZIPCentre.h"
#import "ZIPDownloader.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"

@interface DownloadManagerTableViewController ()
@property ZIPCentre *zipCenre;
@property NSMutableArray *comics;
@end

@implementation DownloadManagerTableViewController
@synthesize zipCenre;
@synthesize comics;


- (void)viewDidLoad
{
    [super viewDidLoad];
    zipCenre = [ZIPCentre getInstance];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshComics];
}

-(void)refreshComics {
    comics = [NSMutableArray new];
    [comics addObjectsFromArray:zipCenre.downloadingZip.array];
    [comics addObjectsFromArray:zipCenre.downloadQueue.array];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return comics.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comic_cell_identifier" forIndexPath:indexPath];
    
    if (cell) {
        UIImageView *coverImageView = (UIImageView*)[cell viewWithTag:1];
        UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
        UIButton *stopButton = (UIButton*)[cell viewWithTag:3];
        id object = [comics objectAtIndex:indexPath.row];
        Comic *comic;
        if ([object isKindOfClass:[Comic class]]) {
            comic = (Comic*)object;
            [stopButton setTitle:@"WAITING" forState:UIControlStateNormal];
            [stopButton setBackgroundColor:[UIColor cyanColor]];
            [stopButton removeTarget:self action:@selector(stopDownloadingComic:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            comic = [(ZIPDownloader*)object comic];
            [stopButton setTitle:@"STOP" forState:UIControlStateNormal];
            [stopButton setBackgroundColor:[UIColor redColor]];
            [stopButton addTarget:self action:@selector(stopDownloadingComic:) forControlEvents:UIControlEventTouchUpInside];
        }
        //assign properties of comic to this cell
        //name
        titleLabel.text = comic.name;
        //cover
        if (comic.cover) {
            coverImageView.image = comic.cover;
            [coverImageView setAlpha:1.0];
        } else {
            [coverImageView setAlpha:0.5];
            coverImageView.image = [UIImage imageNamed:@"icon_144"];
        }
        //modify the look
        stopButton.layer.masksToBounds = NO;
        stopButton.layer.cornerRadius = 2;
        stopButton.layer.shadowOffset = CGSizeMake(1, 1);
        stopButton.layer.shadowRadius = 2;
        stopButton.layer.shadowOpacity = 0.3;
        coverImageView.layer.masksToBounds = NO;
        coverImageView.layer.cornerRadius = 2;
        coverImageView.layer.shadowOffset = CGSizeMake(1, 1);
        coverImageView.layer.shadowRadius = 2;
        coverImageView.layer.shadowOpacity = 0.3;
    }
    return cell;
}

-(void)stopDownloadingComic:(UIButton*)buttonTapped {
    UIView *parentView = buttonTapped.superview;
    while (![parentView isKindOfClass:[UITableViewCell class]] && parentView) {
        parentView = parentView.superview;
    }
    if (!parentView)
        return;
    id object = [comics objectAtIndex:[self.tableView indexPathForCell:(UITableViewCell*)parentView].row];
    Comic *comicToStop;
    if ([object isKindOfClass:[ZIPDownloader class]])
    {
        comicToStop = [(ZIPDownloader*)object comic];
    } else {
        comicToStop = (Comic*)object;
    }
    [zipCenre stopDownloadingComic:comicToStop];
    [self refreshComics];
    [[[AppDelegate sharedAppDelegate] window] makeToast:[NSString stringWithFormat:@"The downloading of %@ has been stopped", comicToStop.name]];
    if (self.downloadIndicator)
        [self.downloadIndicator minusNumber];
}

@end
