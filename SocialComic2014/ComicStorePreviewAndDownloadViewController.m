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
    coverView.layer.masksToBounds = NO;
    coverView.layer.cornerRadius = 5;
    coverView.layer.shadowOffset = CGSizeMake(1, 2);
    coverView.layer.shadowRadius = 5;
    coverView.layer.shadowOpacity = 0.5;
    //listen to downloading notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloaded:) name:@"ZIPDownloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloadProgressUpdated:) name:@"ZipDownloadProgressUpdate" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - set my comic
-(void)setMyComic:(Comic *)comic {
    myComic = comic;
    comicReady = NO;
    if (myComic.cover) {
        comicCoverPreviewImageView.image = myComic.cover;
    } else {
        comicCoverPreviewImageView.image = [UIImage imageNamed:@"NoImageAvailable"];
    }
    if ([zipCentre containsComic:comic]){
        [downloadButton setTitle:@"DOWNLOADING..." forState:UIControlStateNormal];
    } else {
        [downloadButton setTitle:@"DOWNLOAD" forState:UIControlStateNormal];
    }
    if ([localComicSingleton containsComic:myComic]) {
        [downloadButton setTitle:@"COMIC IS READY" forState:UIControlStateNormal];
        comicReady = YES;
    }
    [self.view setNeedsDisplay];
}

- (IBAction)downloadAction:(id)sender {
    if (comicReady) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:1] forKey:@"ShouldOpenTab"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShouldOpenTabCommand" object:self userInfo:userInfo];
    }
    if (myComic && myComic.zipFileURL && !comicReady)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:myComic forKey:@"SelectedComic"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShouldDownloadComicCommand" object:nil userInfo:userInfo];
    }
    [self dismissSelf];
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
            NSLog(@"comic downloaded");
            [downloadButton setTitle:@"COMIC IS READY" forState:UIControlStateNormal];
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
        NSString *buttonTitle = [NSString stringWithFormat:@"DOWNLOADING...%d%%", (NSInteger)progress];
        [downloadButton setTitle:buttonTitle forState:UIControlStateNormal];
    }
}
@end
