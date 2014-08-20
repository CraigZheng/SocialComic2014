//
//  ComicPagingScrollViewController.m
//  SocialComic2014
//
//  Created by Craig on 27/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ComicPagingScrollViewController.h"
#import "ComicViewingViewController.h"
#import "ComicReaderTabBarViewController.h"
#import "MWPhotoBrowser.h"

@interface ComicPagingScrollViewController ()<UIScrollViewDelegate, MWPhotoBrowserDelegate>
@property NSMutableArray *comicFiles;
@property NSInteger currentPage;
@property NSMutableArray *viewControllers;
@property NSTimer *autoDismissToolbarsTimer;
@property MWPhotoBrowser *browser;
@end

@implementation ComicPagingScrollViewController
@synthesize scrollView;
@synthesize myComic;
@synthesize comicFiles;
@synthesize currentPage;
@synthesize viewControllers;
@synthesize bottomToolbar;
@synthesize autoDismissToolbarsTimer;
@synthesize navigationBar;
@synthesize pageNumberButton;
@synthesize browser;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    navigationBar.hidden = YES;
    bottomToolbar.hidden = YES;
    self.view.frame = [UIScreen mainScreen].bounds;
    self.title = myComic.name;
    navigationBar.topItem.title = myComic.name;
    
    comicFiles = [NSMutableArray new];
    viewControllers = [NSMutableArray new];
    if (!myComic){
        return;
    }
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:myComic.unzipToFolder error:nil];
    for (NSString *file in files) {
        if ([file hasSuffix:@"png"]
            || [file hasSuffix:@"jpg"]
            || [file hasSuffix:@"jpeg"]
            || [file hasSuffix:@"gif"]) {
//            [comicFiles addObject:[myComic.unzipToFolder stringByAppendingPathComponent:file]];
            NSString *filePath = [myComic.unzipToFolder stringByAppendingPathComponent:file];
            [comicFiles addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:filePath]]];
            [viewControllers addObject:[NSNull null]];
        }
    }
//    [self loadComicPages];
    currentPage = 0;
//    [self alignCurrentPageWithAnimation:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
//    browser.displayActionButton = NO; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = YES; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.wantsFullScreenLayout = YES; // iOS 5 & 6 only: Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    browser.delayToHideElements = 2.0;
    
    [browser setCurrentPhotoIndex:0];
    [browser scrollViewToTop];
    [self.navigationController pushViewController:browser animated:YES];
}

-(void)loadComicPages {
    CGFloat windowWidth = [[[AppDelegate sharedAppDelegate] window] frame].size.width;
    if (!UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        windowWidth = [[[AppDelegate sharedAppDelegate] window] frame].size.height;
    }
//    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame) * comicFiles.count, CGRectGetHeight(scrollView.frame));
    scrollView.contentSize = CGSizeMake(windowWidth * comicFiles.count, CGRectGetHeight(scrollView.frame));
    for (int i = 0; i < viewControllers.count; i++) {
        [self loadScrollViewWithPage:i];
    }
}

//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [self showToolbars: YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextAction:) name:NEXT_PAGE_COMMAND object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previousAction:) name:PREVIOUS_PAGE_COMMAND object:nil];
//    [AppDelegate sharedAppDelegate].shouldAllowMultipleInterfaceOrientation = YES;
//}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [AppDelegate sharedAppDelegate].shouldAllowMultipleInterfaceOrientation = NO;
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.comicFiles.count)
        return;
    // replace the placeholder if necessary
    ComicViewingViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[ComicViewingViewController alloc] initWithNibName:@"ComicViewingViewController" bundle:[NSBundle mainBundle]];
        controller.comicFile = [comicFiles objectAtIndex:page];
        controller.parentPagingScrollView = self;
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = CGRectGetWidth(frame) * page;
    frame.origin.y = 0;
    controller.view.frame = frame;
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    currentPage = page;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
//    [self loadScrollViewWithPage:page - 1];
//    [self loadScrollViewWithPage:page];
//    [self loadScrollViewWithPage:page + 1];
    
//    for (ComicViewingViewController *viewingViewController in self.viewControllers) {
//        if ((NSNull*)viewingViewController != [NSNull null])
//            viewingViewController.scrollView.userInteractionEnabled = YES;
//    }

    // a possible optimization would be to unload the views+controllers which are no longer visible
    
}

- (void)alignCurrentPageWithAnimation:(BOOL)animated
{
    NSInteger page = currentPage;
    [pageNumberButton setTitle:[NSString stringWithFormat:@"%ld/%ld", (long)page + 1, (long)self.comicFiles.count + 1]];

    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
//    [self loadScrollViewWithPage:page - 1];
//    [self loadScrollViewWithPage:page];
//    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
    [self updateAutoDismissTimer];
}


-(void)setupToolbars {

    bottomToolbar.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.size.height - bottomToolbar.frame.size.height, scrollView.frame.size.width, bottomToolbar.frame.size.height);
}

-(void)showToolbars:(BOOL)animated {
    if (animated) {
        [[AppDelegate sharedAppDelegate] doSingleViewShowAnimation:navigationBar :kCATransitionFromBottom :0.3];
        [[AppDelegate sharedAppDelegate] doSingleViewShowAnimation:bottomToolbar :kCATransitionFromTop :0.3];
    } else {
        [[AppDelegate sharedAppDelegate] doSingleViewShowAnimation:navigationBar :kCATransitionFromBottom :0.01];
        [[AppDelegate sharedAppDelegate] doSingleViewShowAnimation:bottomToolbar :kCATransitionFromTop :0.01];
    }
    [self updateAutoDismissTimer];
}

-(void)updateAutoDismissTimer {
    if (autoDismissToolbarsTimer.isValid)
        [autoDismissToolbarsTimer invalidate];
    autoDismissToolbarsTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideToolbars:) userInfo:nil repeats:NO];
}

-(void)hideToolbars:(BOOL)animated {
    if (animated) {
        [[AppDelegate sharedAppDelegate] doSingleViewHideAnimation:navigationBar :kCATransitionFromTop :0.3];
        [[AppDelegate sharedAppDelegate] doSingleViewHideAnimation:bottomToolbar :kCATransitionFromBottom :0.3];
    } else {
        [[AppDelegate sharedAppDelegate] doSingleViewHideAnimation:navigationBar :kCATransitionFromTop :0.01];
        [[AppDelegate sharedAppDelegate] doSingleViewHideAnimation:bottomToolbar :kCATransitionFromBottom :0.01];
    }
}

- (IBAction)quitAction:(id)sender {
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
    else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        UITabBarController *comicViewingTabBarController = [storyBoard instantiateViewControllerWithIdentifier:@"comic_reader_tab_bar_controller"];
        comicViewingTabBarController.selectedIndex = 1; //show library view controller
        [AppDelegate sharedAppDelegate].window.rootViewController = comicViewingTabBarController;
    }
}

- (IBAction)previousAction:(id)sender {
    if (currentPage > 0) {
        currentPage --;
        [self alignCurrentPageWithAnimation:YES];
    }
    [self updateAutoDismissTimer];
}

- (IBAction)nextAction:(id)sender {
    if (currentPage < comicFiles.count) {
        currentPage ++;
        [self alignCurrentPageWithAnimation:YES];
    }
    [self updateAutoDismissTimer];
}

- (IBAction)tapOnViewAction:(id)sender {
    if (navigationBar.hidden) {
        [self showToolbars:YES];
    } else {
        [self hideToolbars:YES];
    }
}

- (IBAction)JumpToAction:(id)sender {
    
}

#pragma mark - rotation
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    [self hideToolbars:NO];
    currentPage = browser.currentIndex;
//    for (UIViewController *controller in viewControllers) {
//        if ((NSNull*)controller != [NSNull null])
//            [controller willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    [self loadComicPages];
//    [self alignCurrentPageWithAnimation:NO];
//    [self showToolbars:YES];
    [browser setCurrentPhotoIndex:currentPage];
    //    for (UIViewController* controller in viewControllers) {
//        if ((NSNull*)controller != [NSNull null])
//            [controller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    }
    
}

#pragma mark - MWPhotoBrowserDelegate
-(id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.comicFiles.count)
        return [self.comicFiles objectAtIndex:index];
    return nil;
}

-(NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return comicFiles.count;
}
@end
