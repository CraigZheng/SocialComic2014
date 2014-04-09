//
//  ComicStoreViewController.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ComicStoreViewController.h"
#import "XMLDownloader.h"
#import "XMLProsessor.h"
#import "Comic.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "ImageCentre.h"
#import "DACircularProgressView.h"

@interface ComicStoreViewController ()<XMLDownloaderDelegate>
@property NSArray *comics;
@property ImageCentre *imageCentre;
@end

@implementation ComicStoreViewController
@synthesize comics;
@synthesize imageCentre;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    comics = [NSArray new];
    [self startDownloadingComicList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:@"ImageDownloaded" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloadProgressUpdated:) name:@"ImageDownloadProgressUpdated" object:nil];
}

-(void)startDownloadingComicList{
    imageCentre = [ImageCentre new];
    XMLDownloader *xmlDownloader = [XMLDownloader new];
    xmlDownloader.delegate = self;
    [xmlDownloader downloadXML];
    [[[AppDelegate sharedAppDelegate] window] makeToastActivity];
}

-(void)downloadOfXMLCompleted:(BOOL)success :(NSData *)xmlData{
    if (success){
        comics = [[XMLProsessor new] parseXML:xmlData];
        //download all the covers
        for (Comic *comic in comics) {
            [imageCentre downloadImageWithURL:comic.coverFileURL];
        }
        NSLog(@"size %d", comics.count);
        [self.tableView reloadData];
    }
    [[[AppDelegate sharedAppDelegate] window] hideToastActivity];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return comics.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //last cell
    if (indexPath.row == comics.count) {
        return [tableView dequeueReusableCellWithIdentifier:@"refresh_cell_identifier" forIndexPath:indexPath];
    }
    NSString *identifier = @"comic_cell_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell) {
        UIImageView *coverImageView = (UIImageView*)[cell viewWithTag:1];
        UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
        UITextView *descriptionTextView = (UITextView*)[cell viewWithTag:3];
        //UIButton *downloadButton = (UIButton*)[cell viewWithTag:4];
        DACircularProgressView *circularView = (DACircularProgressView*)[cell viewWithTag:5];
        
        //[downloadButton addTarget:self action:@selector(downloadComic:) forControlEvents:UIControlEventTouchUpInside];
        //assign properties of comic to this cell
        Comic *comic = [comics objectAtIndex:indexPath.row];
        titleLabel.text = comic.zipFileURL.lastPathComponent;
        if (comic.localCoverFile) {
            UIImage *image = [UIImage imageWithContentsOfFile:comic.localCoverFile];
            if (image) {
                coverImageView.image = image;
                [coverImageView setAlpha:1.0];
                circularView.hidden = YES;
            }
            else {
                //TODO: change the image to indicate that the cover file has yet to be downloaded
                [coverImageView setAlpha:0.5];
                circularView.hidden = NO;
            }
        }
    }
    
    return cell;
}

#pragma mark notification handler - image downloading progress update
-(void)imageDownloadProgressUpdated:(NSNotification*)notification{
    NSString *imgURL = [notification.userInfo objectForKey:@"ImageURL"];
    CGFloat progress = [[notification.userInfo objectForKey:@"Progress"] floatValue];
    if (imgURL){
        NSInteger updateIndex = -1;
        for (Comic *comic in comics) {
            if ([comic.coverFileURL isEqualToString:imgURL]){
                updateIndex = [comics indexOfObject:comic];
                break;
            }
        }
        if (updateIndex > -1){
            UITableViewCell *cellToUpdate = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:updateIndex inSection:0]];
            DACircularProgressView *circularProgressView = (DACircularProgressView*)[cellToUpdate viewWithTag:5];
            UIImageView *coverImageView = (UIImageView*)[cellToUpdate viewWithTag:1];
            circularProgressView.trackTintColor = [UIColor lightGrayColor];
            if (circularProgressView){
                if (progress < 1.0f)
                {
                    circularProgressView.hidden = NO;
                    circularProgressView.progress = progress;
                    [coverImageView setAlpha:0.5];

                } else {
                    circularProgressView.hidden = YES;
                }
                [circularProgressView setNeedsDisplay];
            }
        }
    }
}


-(void)downloadComic:(id)sender {
    UIView *view = [sender superview];
    while (view != [UITableViewCell class]) {
        view = [view superview];
    }
    UITableViewCell *cell = (UITableViewCell*)view;
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:cell];
    Comic *selectedComic = [comics objectAtIndex:selectedIndexPath.row];
    //TODO: download zip file for the comic
}

#pragma mark - NSNotification handler - image downloaded
-(void)imageDownloaded:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo objectForKey:@"Success"] boolValue]) {
        NSString *saveToPath = [userInfo objectForKey:@"SavePath"];
        for (Comic *comic in comics) {
            if ([comic.coverFileURL isEqualToString:[userInfo objectForKey:@"ImageURL"]]) {
                comic.localCoverFile = saveToPath;
            }
        }
        [self.tableView reloadData];
    }
}
@end
