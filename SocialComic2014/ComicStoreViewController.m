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
#import "ImageCentre.h"

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
    imageCentre = [ImageCentre new];
    XMLDownloader *xmlDownloader = [XMLDownloader new];
    xmlDownloader.delegate = self;
    [xmlDownloader downloadXML];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:@"ImageDownloaded" object:nil];
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
        UIButton *downloadButton = (UIButton*)[cell viewWithTag:4];
        [downloadButton addTarget:self action:@selector(downloadComic:) forControlEvents:UIControlEventTouchUpInside];
        //assign properties of comic to this cell
        Comic *comic = [comics objectAtIndex:indexPath.row];
        titleLabel.text = comic.zipFileURL.lastPathComponent;
        //cover image - TODO: load freshly downloaded image
        if (comic.coverFile) {
            UIImage *image = [UIImage imageWithContentsOfFile:comic.coverFile.absoluteString];
            coverImageView.image = image;
        }
    }
    
    return cell;
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
                comic.coverFile = [NSURL fileURLWithPath:saveToPath];
            }
        }
        [self.tableView reloadData];
    }
}
@end
