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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupImageViewForPortrait];
    [self.view addSubview:[self makeToolbar]];
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
    NSLog(@"minimumscale %f", scrollView.minimumZoomScale);
}

-(void)setupImageViewForLandscape {
    [scrollView setZoomScale:1];
    CGRect frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.image.size.width, imageView.image.size.height);
    
    imageView.frame = frame;
    
    scrollView.contentSize = imageView.frame.size;
    scrollView.maximumZoomScale = 1;
    scrollView.minimumZoomScale = self.view.frame.size.height / imageView.image.size.width;
    [scrollView setZoomScale:scrollView.minimumZoomScale];
    [self logViewFrames];
    NSLog(@"minimumscale %f", scrollView.minimumZoomScale);
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

-(UIToolbar*)makeToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *quitItem = [[UIBarButtonItem alloc] initWithTitle:@"QUIT" style:UIBarButtonItemStyleBordered target:self action:@selector(quitComicViewingMode)];
    
    toolbar.items = @[quitItem];
    
    return toolbar;
}

-(void)quitComicViewingMode {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    UITabBarController *comicViewingTabBarController = [storyBoard instantiateViewControllerWithIdentifier:@"comic_reader_tab_bar_controller"];
    [UIView transitionWithView:[AppDelegate sharedAppDelegate].window
                      duration:0.2
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{ [AppDelegate sharedAppDelegate].window.rootViewController = comicViewingTabBarController; }
                    completion:nil];

}
@end
