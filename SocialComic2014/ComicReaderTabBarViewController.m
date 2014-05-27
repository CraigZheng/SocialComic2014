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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldOpenTab:) name:@"ShouldOpenTabCommand" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloaded:) name:@"ZIPDownloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloadStarted:) name:@"ZipDownloadStarted" object:nil];
    thinDownloadIndicatorViewController = [[ThinDownloadIndicatorViewController alloc] initWithNibName:@"ThinDownloadIndicatorViewController" bundle:[NSBundle mainBundle]];
    thinDownloadIndicatorViewController.view.frame = CGRectMake(
                                                                self.view.frame.size.width - thinDownloadIndicatorViewController.view.frame.size.width - thinDownloadIndicatorViewController.view.frame.size.width / 2,
                                                                self.tabBar.frame.origin.y - thinDownloadIndicatorViewController.view.frame.size.height - thinDownloadIndicatorViewController.view.frame.size.height / 2,
                                                                thinDownloadIndicatorViewController.view.frame.size.width,
                                                                thinDownloadIndicatorViewController.view.frame.size.height);
    [self.view addSubview:thinDownloadIndicatorViewController.view];
    [thinDownloadIndicatorViewController hide];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

@end
