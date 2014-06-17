//
//  ComicReaderTabBarViewController.m
//  SocialComic2014
//
//  Created by Craig on 23/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ComicReaderTabBarViewController.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "ThinDownloadIndicatorViewController.h"
#import "ZIPCentre.h"

@interface ComicReaderTabBarViewController ()
@property ThinDownloadIndicatorViewController *thinDownloadIndicatorViewController;
@end

@implementation ComicReaderTabBarViewController
@synthesize thinDownloadIndicatorViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldOpenTab:) name:@"ShouldOpenTabCommand" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloaded:) name:@"ZIPDownloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloadStarted:) name:@"ZipDownloadStarted" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    thinDownloadIndicatorViewController = [[ThinDownloadIndicatorViewController alloc] initWithNibName:@"ThinDownloadIndicatorViewController" bundle:[NSBundle mainBundle]];
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
//    thinDownloadIndicatorViewController.view.frame = CGRectMake(
//                                                                [UIScreen mainScreen].bounds.size.width - thinDownloadIndicatorViewController.view.frame.size.width - thinDownloadIndicatorViewController.view.frame.size.width / 2,
//                                                                self.tabBar.frame.origin.y - thinDownloadIndicatorViewController.view.frame.size.height - thinDownloadIndicatorViewController.view.frame.size.height / 2,
//                                                                thinDownloadIndicatorViewController.view.frame.size.width,
//                                                                thinDownloadIndicatorViewController.view.frame.size.height);
    [thinDownloadIndicatorViewController.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OpenMyLibraryTab)]];
    [thinDownloadIndicatorViewController hide];
}

#pragma mark - Rotation events
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [thinDownloadIndicatorViewController hide];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    CGRect indicatorFrame = thinDownloadIndicatorViewController.view.frame;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        screenWidth = [UIScreen mainScreen].bounds.size.height;
        screenHeight = [UIScreen mainScreen].bounds.size.width;
    }
    indicatorFrame.origin.x = screenWidth - thinDownloadIndicatorViewController.view.frame.size.width - thinDownloadIndicatorViewController.view.frame.size.width / 2;
    indicatorFrame.origin.y = screenHeight - thinDownloadIndicatorViewController.view.frame.size.height - thinDownloadIndicatorViewController.view.frame.size.height / 2;
    indicatorFrame.size.width = 50;
    indicatorFrame.size.height = 50;
    
    thinDownloadIndicatorViewController.view.frame = indicatorFrame;
    if (thinDownloadIndicatorViewController.isSpinning) {
        if (!thinDownloadIndicatorViewController.view.superview)
            [self.view addSubview:thinDownloadIndicatorViewController.view];
        [thinDownloadIndicatorViewController show];
    }
}

#pragma mark - notification handler

-(void)zipDownloaded:(NSNotification*)notification {
    if (self.selectedIndex != 1) {
        UITabBarItem *selectedItem = [self.tabBar.items objectAtIndex:1];
        if (selectedItem.badgeValue != nil) {
            NSInteger count = [selectedItem.badgeValue integerValue] + 1;
            selectedItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)count];
        } else {
            selectedItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)1];
        }
    }
    if ([[ZIPCentre getInstance] downloadingZip].count == 0 && [[ZIPCentre getInstance] downloadQueue].count == 0) {
        [thinDownloadIndicatorViewController hide];
        [thinDownloadIndicatorViewController stopAnimation];
    }
}

-(void)zipDownloadStarted:(NSNotification*)notification {
    if (thinDownloadIndicatorViewController.view.hidden) {
        if (!thinDownloadIndicatorViewController.view.superview)
            [self.view addSubview:thinDownloadIndicatorViewController.view];
        [thinDownloadIndicatorViewController show];
        [thinDownloadIndicatorViewController beginAnimation];
    }
}

-(void)shouldOpenTab:(NSNotification*)notification {
    NSInteger shouldOpenTabIndex = [[notification.userInfo objectForKey:@"ShouldOpenTab"] integerValue];
    self.selectedIndex = shouldOpenTabIndex;
    NSString *message = [notification.userInfo objectForKey:@"Message"];
    if (message) {
        [[[AppDelegate sharedAppDelegate] window] makeToast:message duration:1.0 position:@"bottom"];
    }
}

-(void)OpenStoreTab {
    self.selectedIndex = 0;
}
-(void)OpenMyLibraryTab {
    self.selectedIndex = 1;
}
@end
