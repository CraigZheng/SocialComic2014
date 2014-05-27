//
//  ComicViewingViewController.m
//  SocialComic2014
//
//  Created by Craig on 7/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ComicViewingViewController.h"
#import "AppDelegate.h"

@interface ComicViewingViewController ()
@end

@implementation ComicViewingViewController
@synthesize scrollView;
@synthesize imageView;
@synthesize comicFile;
@synthesize topToolbar;
@synthesize bottomToolbar;
@synthesize topToolbarQuitButton;
@synthesize topToolbarTitleButton;
@synthesize myComic;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    topToolbar.hidden = YES;
    bottomToolbar.hidden = YES;
    
    if (myComic.unzipToFolder) {
        NSArray *comicFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:myComic.unzipToFolder error:nil];
        comicFile = [myComic.unzipToFolder stringByAppendingPathComponent:comicFiles.firstObject];
        imageView.image = [UIImage imageWithContentsOfFile:comicFile];
    }
    
    [self setupImageViewForPortrait];
    [self setupToolbars];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[AppDelegate sharedAppDelegate] doSingleViewShowAnimation:topToolbar :kCATransitionFromBottom :0.3];
    [[AppDelegate sharedAppDelegate] doSingleViewShowAnimation:bottomToolbar :kCATransitionFromTop :0.3];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        //[self performSelector:@selector(setupImageViewForLandscape) withObject:nil afterDelay:0.5];
        [self setupImageViewForLandscape];
    } else {
        [self setupImageViewForPortrait];
    }
    //imageview is hidden before, show imageview
    [UIView beginAnimations:@"ShowImageView" context:nil];
    [UIView setAnimationDuration:0.1];
    imageView.alpha = 1.0;
    [UIView commitAnimations];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //black out imageview to hide the ugly transformation
    imageView.alpha = 1.0;
    [UIView beginAnimations:@"HideImageView" context:nil];
    [UIView setAnimationDuration:0.1];
    imageView.alpha = 0;
    [UIView commitAnimations];
    
}

-(void)setupImageViewForPortrait {
    [scrollView setZoomScale:1];
    self.view.frame = [UIScreen mainScreen].bounds;
    scrollView.frame = self.view.frame;
    imageView.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
    scrollView.contentSize = imageView.frame.size;
    scrollView.maximumZoomScale = 1;
    scrollView.minimumZoomScale = self.view.frame.size.height / imageView.image.size.height;
    [scrollView setZoomScale:scrollView.minimumZoomScale];
    [self logViewFrames];
    NSLog(@"minimumscale %f / current scale %f", scrollView.minimumZoomScale, scrollView.zoomScale);
}

-(void)setupImageViewForLandscape {
    [scrollView setZoomScale:1];
    
    CGRect frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.image.size.width, imageView.image.size.height);
    
    imageView.frame = frame;
    
    scrollView.contentSize = imageView.frame.size;
    scrollView.maximumZoomScale = 1;
    scrollView.minimumZoomScale = self.view.frame.size.width / imageView.image.size.width;
    [scrollView setZoomScale:scrollView.minimumZoomScale];
    [self logViewFrames];
    NSLog(@"minimumscale %f / current scale %f", scrollView.minimumZoomScale, scrollView.zoomScale);
}

-(void)setupToolbars {
    topToolbar.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, topToolbar.frame.size.height);
    bottomToolbar.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.size.height - bottomToolbar.frame.size.height, scrollView.frame.size.width, topToolbar.frame.size.height);
}

-(void)logViewFrames{
    [self logViewFrame:[[AppDelegate sharedAppDelegate] window]];
    [self logViewFrame:self.view];
    [self logViewFrame:scrollView];
    NSLog(@"contentSize : %@", [NSValue valueWithCGSize:scrollView.contentSize]);
    [self logViewFrame:imageView];
}

-(void)logViewFrame:(UIView*)view {
    NSLog(@"%@ : %@", view.class, [NSValue valueWithCGRect:view.frame]);
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

-(void)quitComicViewingMode {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    UITabBarController *comicViewingTabBarController = [storyBoard instantiateViewControllerWithIdentifier:@"comic_reader_tab_bar_controller"];
    comicViewingTabBarController.selectedIndex = 1; //show library view controller
    [AppDelegate sharedAppDelegate].window.rootViewController = comicViewingTabBarController;
//    [UIView transitionWithView:[AppDelegate sharedAppDelegate].window
//                      duration:0.2
//                       options:UIViewAnimationOptionCurveEaseInOut
//                    animations:^{ [AppDelegate sharedAppDelegate].window.rootViewController = comicViewingTabBarController; }
//                    completion:nil];

}

- (IBAction)topToolbarQuitAction:(id)sender {
    [self quitComicViewingMode];
}
@end
