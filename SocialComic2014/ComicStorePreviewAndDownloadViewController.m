//
//  ComicStorePreviewAndDownloadViewController.m
//  SocialComic2014
//
//  Created by Craig on 23/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ComicStorePreviewAndDownloadViewController.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "ZIPCentre.h"
#import <QuartzCore/QuartzCore.h>
#import "ZIPDownloader.h"
#import "LocalComicSingleton.h"

@interface ComicStorePreviewAndDownloadViewController ()
@property ZIPCentre *zipCentre;
@property LocalComicSingleton *localComicSingleton;
@property BOOL comicReady;
@end

@implementation ComicStorePreviewAndDownloadViewController
@synthesize comicCoverPreviewImageView;
@synthesize myComic;
@synthesize coverView;
@synthesize stopDownloadButton;
@synthesize downloadButton;
@synthesize zipCentre;
@synthesize localComicSingleton;
@synthesize comicReady;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tapToFadeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf)];
    [tapToFadeGestureRecognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tapToFadeGestureRecognizer];
    zipCentre = [ZIPCentre getInstance];
    localComicSingleton = [LocalComicSingleton getInstance];
    //change the view a bit
    [downloadButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    coverView.layer.masksToBounds = NO;
    coverView.layer.cornerRadius = 3;
    coverView.layer.shadowOffset = CGSizeMake(1, 2);
    coverView.layer.shadowRadius = 5;
    coverView.layer.shadowOpacity = 0.5;
    stopDownloadButton.layer.masksToBounds = NO;
    stopDownloadButton.layer.cornerRadius = 3;
    stopDownloadButton.layer.shadowOffset = CGSizeMake(2, 2);
    stopDownloadButton.layer.shadowRadius = 5;
    stopDownloadButton.layer.shadowOpacity = 0.5;
    comicCoverPreviewImageView.layer.masksToBounds = NO;
    comicCoverPreviewImageView.layer.cornerRadius = 3;
    comicCoverPreviewImageView.layer.shadowOffset = CGSizeMake(2, 2);
    comicCoverPreviewImageView.layer.shadowRadius = 5;
    comicCoverPreviewImageView.layer.shadowOpacity = 0.5;
    //listen to downloading notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloaded:) name:@"ZIPDownloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloadProgressUpdated:) name:@"ZipDownloadProgressUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:@"ImageDownloaded" object:nil];

}


#pragma mark - set my comic
-(void)setMyComic:(Comic *)comic {
    myComic = comic;
    comicReady = NO;
    if (myComic.cover) {
        comicCoverPreviewImageView.image = myComic.cover;
    } else {
        comicCoverPreviewImageView.image = [UIImage imageNamed:@"NoImageAvailable.jpg"];
    }
    [downloadButton setTitle:nil forState:UIControlStateNormal];
    [downloadButton setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
    if ([localComicSingleton containsComic:myComic]) {
        [downloadButton setImage:[UIImage imageNamed:@"open_book.png"] forState:UIControlStateNormal];
        comicReady = YES;
    }
}

-(void)resetViews{
    stopDownloadButton.hidden = YES;
    stopDownloadButton.alpha = 0;
    if ([zipCentre containsComic:myComic] && !comicReady){
        [downloadButton setTitle:@"DOWNLOADING..." forState:UIControlStateNormal];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        stopDownloadButton.alpha = 1;
        stopDownloadButton.hidden = NO;
        [UIView commitAnimations];
    }
}

- (IBAction)downloadAction:(id)sender {
    if (comicReady) {
        [self dismissSelf];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInteger:1]] forKeys:@[@"ShouldOpenTab",]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShouldOpenTabCommand" object:self userInfo:userInfo];
        return;
    }
    if (myComic && myComic.zipFileURL && !comicReady)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:myComic forKey:@"SelectedComic"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShouldDownloadComicCommand" object:nil userInfo:userInfo];
        /*
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        stopDownloadButton.alpha = 1;
        stopDownloadButton.hidden = NO;
        [UIView commitAnimations];
         */
        [self dismissSelf];
        return;
    }
    //[self performSelector:@selector(resetViews) withObject:nil afterDelay:1];
}

- (IBAction)stopDownloadAction:(id)sender {
    [zipCentre stopDownloadingComic:myComic];
    [self resetViews];
    [[[AppDelegate sharedAppDelegate] window] makeToast:[NSString stringWithFormat:@"The download of %@ has been stopped", myComic.name] duration:1.5 position:@"bottom"];
}

-(void)dismissSelf {
    if ([self.view superview]) {
        [AppDelegate fadeOutView:self.view];
    }
}

#pragma mark - ZIPCentre notification handlers
-(void)zipDownloaded:(NSNotification*)notification {
    if ([[notification.userInfo objectForKey:@"Success"] boolValue]) {
        ZIPDownloader *downloader = [notification.userInfo objectForKey:@"ZIPDownloader"];
        if ([downloader.comic isEqual:myComic]) {
            [downloadButton setTitle:nil forState:UIControlStateNormal];
            [downloadButton setImage:[UIImage imageNamed:@"open_book.png"] forState:UIControlStateNormal];
            comicReady = YES;
        }
    }
}

-(void)zipDownloadProgressUpdated:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat progress = [[userInfo objectForKey:@"Progress"] floatValue];
    progress *= 100;
    ZIPDownloader *downloader = [userInfo objectForKey:@"ZIPDownloader"];
    if ([downloader.comic isEqual:myComic]) {
        [UIView setAnimationsEnabled:NO];
        NSString *buttonTitle = [NSString stringWithFormat:@"%d%%...", (NSInteger)progress];
        [downloadButton setImage:nil forState:UIControlStateNormal];
        [downloadButton setTitle:buttonTitle forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
    }
}

#pragma mark - image downloaded notification 
-(void)imageDownloaded:(NSNotification*)notification {
    
}
@end
