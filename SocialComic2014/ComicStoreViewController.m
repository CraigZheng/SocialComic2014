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
#import "ZIPCentre.h"
#import "TXTCentre.h"
#import "DACircularProgressView.h"
#import "LocalComicSingleton.h"
#import "ComicStorePreviewAndDownloadViewController.h"
#import "ComicDownloadIndicatorViewController.h"
#import "DownloadManagerTableViewController.h"
#import "FPPopoverController.h"

@interface ComicStoreViewController ()<XMLDownloaderDelegate>
@property NSArray *comics;
@property ImageCentre *imageCentre;
@property TXTCentre *txtCentre;
@property ZIPCentre *zipCentre;
@property AppDelegate *mAppDelegate;
@property ComicStorePreviewAndDownloadViewController *previewAndDownloadController;
//@property ComicDownloadIndicatorViewController *downloadIndicator;
@property DownloadManagerTableViewController *downloadManagerViewController;
@property FPPopoverController *popOverController;
@end

@implementation ComicStoreViewController
@synthesize comics;
@synthesize imageCentre;
@synthesize txtCentre;
@synthesize zipCentre;
@synthesize mAppDelegate;
@synthesize previewAndDownloadController;
//@synthesize downloadIndicator;
@synthesize downloadManagerViewController;
@synthesize popOverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mAppDelegate = [AppDelegate sharedAppDelegate];
    comics = [NSArray new];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
    //add comic preview controller
    previewAndDownloadController = [[ComicStorePreviewAndDownloadViewController alloc] initWithNibName:@"ComicStorePreviewAndDownloadViewController" bundle:[NSBundle mainBundle]];
    //force the preview controller to be loaded into memory
    previewAndDownloadController.view.alpha = 0;
    [self.view addSubview:previewAndDownloadController.view];
    [previewAndDownloadController.view removeFromSuperview];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloadProgressUpdated:) name:@"ImageDownloadProgressUpdated" object:nil];
    //add header view
    UIImage *bannerImage = [UIImage imageNamed:@"bannerImage"];
    UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 640, 116)];
    bannerImageView.image = bannerImage;
    bannerImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.tableView.tableHeaderView = bannerImageView;
    //downloading indicator
//    downloadIndicator = [[ComicDownloadIndicatorViewController alloc] initWithNibName:@"ComicDownloadIndicatorViewController" bundle:[NSBundle mainBundle]];
//    [downloadIndicator.view setFrame:CGRectMake(self.view.frame.size.width - downloadIndicator.view.frame.size.width - 20, self.tabBarController.tabBar.frame.origin.y - downloadIndicator.view.frame.size.height - 20, downloadIndicator.view.frame.size.width, downloadIndicator.view.frame.size.height)];
//    UITapGestureRecognizer *tapOnDownloadIndicator = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnDownloadingIndicator:)];
//    [downloadIndicator.view addGestureRecognizer:tapOnDownloadIndicator];
    //download manager
//    downloadManagerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"downloadManagerViewController"];
//    downloadManagerViewController.downloadIndicator = downloadIndicator;
//    popOverController = [[FPPopoverController alloc] initWithViewController:downloadManagerViewController];
//    popOverController.border = NO;
//    popOverController.tint = FPPopoverWhiteTint;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [[mAppDelegate window] addSubview:downloadIndicator.view];
//    if (downloadIndicator.numberToShow > 0) {
//        [downloadIndicator startAnimating];
//        if (downloadIndicator.hidden)
//            [downloadIndicator show];
//    } else {
//        if (!downloadIndicator.hidden)
//            [downloadIndicator hide];
//    }
    if (comics.count == 0)
        [self startDownloadingComicList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldDownloadComic:) name:@"ShouldDownloadComicCommand" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:@"ImageDownloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(txtDownloaded:) name:@"TXTDownloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloaded:) name:@"ZIPDownloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloadProgressUpdated:) name:@"ZipDownloadProgressUpdate" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [downloadIndicator.view removeFromSuperview];
    [[AppDelegate sharedAppDelegate].window hideToastActivity];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)startDownloadingComicList{
    [[mAppDelegate window] makeToastActivity];
    imageCentre = [ImageCentre getInstance];
    zipCentre = [ZIPCentre getInstance];
    txtCentre = [TXTCentre new];
    XMLDownloader *xmlDownloader = [XMLDownloader new];
    xmlDownloader.delegate = self;
    [xmlDownloader downloadXML];
}

-(void)downloadOfXMLCompleted:(BOOL)success :(NSData *)xmlData{
    if (success){
        comics = [[XMLProsessor new] parseXML:xmlData];
        //download all the covers
        for (Comic *comic in comics) {
            [imageCentre downloadImageWithURL:comic.coverFileURL];
            [txtCentre downloadTXT:comic.descriptionFileURL];
        }
        NSLog(@"size %lu", (unsigned long)comics.count);
        [self.tableView reloadData];
    } else {
        [[[AppDelegate sharedAppDelegate] window] makeToast:@"Unable to connect to server, please try again" duration:1.5 position:@"bottom" title:@"Connection issue" image:[UIImage imageNamed:@"warning"]];
    }
    [[mAppDelegate window] hideToastActivity];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return comics.count + 1;
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
        //name
        Comic *comic = [comics objectAtIndex:indexPath.row];
        titleLabel.text = comic.name;
        //cover
        if (comic.cover) {
            coverImageView.image = comic.cover;
            [coverImageView setAlpha:1.0];
            circularView.hidden = YES;
        } else {
            [coverImageView setAlpha:0.5];
            circularView.hidden = YES;
            coverImageView.image = [UIImage imageNamed:@"icon_144"];
        }
        //description
        if (comic.description.length > 0) {
            descriptionTextView.text = comic.description;
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == comics.count)
        return 44;
    return tableView.rowHeight;
}

-(void)downloadComic:(Comic*)comic {
    [zipCentre downloadComic:comic];
//    [[[AppDelegate sharedAppDelegate] window] makeToast:[NSString stringWithFormat:@"%@ is now being downloaded", comic.name] duration:1.5 position:@"bottom"];
//    [downloadIndicator addNumber];
//    [downloadIndicator show];
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //select last row
    if (indexPath.row == comics.count) {
        [self startDownloadingComicList];
        return;
    }
    Comic *selectedComic = [comics objectAtIndex:indexPath.row];
    previewAndDownloadController.myComic = selectedComic;
    [AppDelegate fadeInView:previewAndDownloadController.view];
    //[self downloadComic:selectedComic];
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


#pragma mark - NSNotification handler - image downloaded
-(void)imageDownloaded:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo objectForKey:@"Success"] boolValue]) {
        NSString *saveToPath = [userInfo objectForKey:@"SavePath"];
        for (Comic *comic in comics) {
            if ([comic.coverFileURL isEqualToString:[userInfo objectForKey:@"ImageURL"]]) {
                comic.localCoverFile = saveToPath;
                NSIndexPath *indexToUpdate = [NSIndexPath indexPathForRow:[comics indexOfObject:comic] inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[indexToUpdate] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        /*
        for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
            
        }
        [self.tableView reloadRowsAtIndexPaths: withRowAnimation:UITableViewRowAnimationAutomatic];
         */
    }
}

#pragma mark - NSNotification handler - txt downloader 
-(void)txtDownloaded:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo objectForKey:@"Success"] boolValue]) {
        for (Comic *comic in comics) {
            if ([comic.descriptionFileURL isEqualToString:[userInfo objectForKey:@"TXTURL"]]) {
                comic.localDescriptionFile = [userInfo objectForKey:@"SavePath"];
                NSIndexPath *indexToUpdate = [NSIndexPath indexPathForRow:[comics indexOfObject:comic] inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[indexToUpdate] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}

#pragma mark - NSNotification handler - zip downloaded
-(void)zipDownloaded:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *savePath = [userInfo objectForKey:@"SavePath"];

    if ([[userInfo objectForKey:@"Success"] boolValue]) {
        NSLog(@"download of zip successed!");
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil message:[NSString stringWithFormat:@"%@ is ready to read in My Library!",
                                                             [[[savePath.lastPathComponent componentsSeparatedByString:@"_"] lastObject] stringByDeletingPathExtension]]
                                  delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    } else {
        NSLog(@"download of zip failed!");
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil message:[NSString stringWithFormat:@"The download of %@ has failed, please try again later", [[[savePath.lastPathComponent componentsSeparatedByString:@"_"] lastObject] stringByDeletingPathExtension]]
                                                             
                                  delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }
//    [downloadIndicator minusNumber];
}

-(void)zipDownloadProgressUpdated:(NSNotification*)notification {
//    NSDictionary *userInfo = notification.userInfo;
//    CGFloat progress = [[userInfo objectForKey:@"Progress"] floatValue];
//    NSString *updateZipURL = [userInfo objectForKey:@"ZIPURL"];
//    NSArray *visibleIndexes = [self.tableView indexPathsForVisibleRows];
//    for (NSIndexPath *indexPath in visibleIndexes) {
//        if (indexPath.row == comics.count)
//            return;
//        Comic *comic = [comics objectAtIndex:indexPath.row];
//        if ([comic.zipFileURL isEqualToString:updateZipURL]) {
//            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//            DACircularProgressView *circularProgressView = (DACircularProgressView*)[cell viewWithTag:5];
//            if (circularProgressView) {
//                circularProgressView.hidden = NO;
//                circularProgressView.alpha = 0.9f;
//                circularProgressView.progress = progress;
//            }
//            if (progress == 1.0f && circularProgressView) {
//                circularProgressView.hidden = YES;
//            }
//        }
//    }
}


#pragma mark - should download comic command received
-(void)shouldDownloadComic:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    Comic *selectedComic = [userInfo objectForKey:@"SelectedComic"];
    if (selectedComic) {
        [self downloadComic:selectedComic];
    }
}

#pragma mark - show pop over view controller, which is the download manager class
-(void)tapOnDownloadingIndicator:(id)sender {
    [downloadManagerViewController refreshComics];
    popOverController.contentSize = CGSizeMake(260, 300);
    [downloadManagerViewController.view setFrame:CGRectMake(downloadManagerViewController.view.frame.origin.x, downloadManagerViewController.view.frame.origin.y, 260, 300)];
//    [popOverController presentPopoverFromView:downloadIndicator.view];
}
@end
