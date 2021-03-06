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
#import "ComicPagingScrollViewController.h"
#import "BookCollectionViewController.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openComicNotificationReceived:) name:COMIC_SELECTED_NOTIFICATION object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    thinDownloadIndicatorViewController = [[ThinDownloadIndicatorViewController alloc] initWithNibName:@"ThinDownloadIndicatorViewController" bundle:[NSBundle mainBundle]];
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
    [thinDownloadIndicatorViewController.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OpenMyLibraryTab)]];
    [thinDownloadIndicatorViewController hide];
}

#pragma mark - Rotation events
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    [thinDownloadIndicatorViewController hide];
    for (id controller in [[AppDelegate sharedAppDelegate] viewControllersAwaitingRotationEvents]) {
        if (controller && [controller isKindOfClass:[UIViewController class]]) {
            [controller willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    CGRect indicatorFrame = thinDownloadIndicatorViewController.view.frame;
    CGFloat screenWidth = [[AppDelegate sharedAppDelegate] window].frame.size.width;
    CGFloat screenHeight = [[AppDelegate sharedAppDelegate] window].frame.size.height;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        screenWidth = [[AppDelegate sharedAppDelegate] window].frame.size.height;
        screenHeight = [[AppDelegate sharedAppDelegate] window].frame.size.width;
    }
    indicatorFrame.origin.x = screenWidth - thinDownloadIndicatorViewController.view.frame.size.width - thinDownloadIndicatorViewController.view.frame.size.width / 2;
    indicatorFrame.origin.y = screenHeight - thinDownloadIndicatorViewController.view.frame.size.height - thinDownloadIndicatorViewController.view.frame.size.height * 1.5;
    indicatorFrame.size.width = 50;
    indicatorFrame.size.height = 50;
    
    thinDownloadIndicatorViewController.view.frame = indicatorFrame;
    if (thinDownloadIndicatorViewController.isSpinning) {
        if (!thinDownloadIndicatorViewController.view.superview)
            [[[AppDelegate sharedAppDelegate] window] addSubview:thinDownloadIndicatorViewController.view];
        [thinDownloadIndicatorViewController show];
    }
    for (id controller in [[AppDelegate sharedAppDelegate] viewControllersAwaitingRotationEvents]) {
        if (controller && [controller isKindOfClass:[UIViewController class]]) {
            [controller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        }
    }

}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
//    if ([AppDelegate sharedAppDelegate].shouldAllowMultipleInterfaceOrientation) {
//        //return all interface orientation
//        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
//    }
//    //return portrait only
//    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - notification handler

-(void)zipDownloaded:(NSNotification*)notification {
    UITabBarItem *bookCollectionTab = [self.tabBar.items objectAtIndex:1];
    if (bookCollectionTab.badgeValue != nil) {
        NSInteger count = [bookCollectionTab.badgeValue integerValue] - 1;
        if (count > 0)
            bookCollectionTab.badgeValue = [NSString stringWithFormat:@"%ld", (long)count];
        else
            bookCollectionTab.badgeValue = nil;
    }
    if ([[ZIPCentre getInstance] downloadingZip].count == 0 && [[ZIPCentre getInstance] downloadQueue].count == 0) {
        [thinDownloadIndicatorViewController hide];
        [thinDownloadIndicatorViewController stopAnimation];
    }
}

-(void)zipDownloadStarted:(NSNotification*)notification {
    UITabBarItem *bookCollectionTab = [self.tabBar.items objectAtIndex:1];
    if (bookCollectionTab) {
        NSInteger count = [bookCollectionTab.badgeValue integerValue] + 1;
        if (count > 0)
            bookCollectionTab.badgeValue = [NSString stringWithFormat:@"%ld", (long)count];
        else
            bookCollectionTab.badgeValue = nil;
    }
    if (thinDownloadIndicatorViewController.view.hidden) {
        if (!thinDownloadIndicatorViewController.view.superview)
            [[[AppDelegate sharedAppDelegate] window] addSubview:thinDownloadIndicatorViewController.view];
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

#pragma mark - open comic notification 
-(void)openComicNotificationReceived:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    self.selectedIndex = 1; //open book collection tab

    if ([[AppDelegate sharedAppDelegate] bookcollectionViewController]) {
        [(BookCollectionViewController*)[[AppDelegate sharedAppDelegate] bookcollectionViewController] openBookmarkComic:[userInfo objectForKey:SELECTED_COMIC_KEY] toPage:[[userInfo objectForKey:SELECTED_PAGE_KEY] integerValue]];
    }
}

-(void)OpenStoreTab {
    self.selectedIndex = 0;
}
-(void)OpenMyLibraryTab {
    self.selectedIndex = 1;
}

@end
