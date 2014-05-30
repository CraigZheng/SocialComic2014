//
//  ComicPagingScrollViewController.m
//  SocialComic2014
//
//  Created by Craig on 27/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ComicPagingScrollViewController.h"
#import "ComicViewingViewController.h"

@interface ComicPagingScrollViewController ()
@property NSMutableArray *comicFiles;
@property NSInteger currentPage;
@property NSMutableArray *viewControllers;
@property NSTimer *autoDismissToolbarsTimer;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    navigationBar.hidden = YES;
    bottomToolbar.hidden = YES;
    self.view.frame = [UIScreen mainScreen].bounds;
    self.title = myComic.name;

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
            [comicFiles addObject:[myComic.unzipToFolder stringByAppendingPathComponent:file]];
            [viewControllers addObject:[NSNull null]];
        }
    }
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame) * comicFiles.count, CGRectGetHeight(scrollView.frame));
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showToolbars: YES];
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.comicFiles.count)
        return;
    
    // replace the placeholder if necessary
    ComicViewingViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
//        controller = [[ComicViewingViewController alloc] initWithPageNumber:page];
        controller = [[ComicViewingViewController alloc] initWithNibName:@"ComicViewingViewController" bundle:[NSBundle mainBundle]];
        controller.comicFile = [comicFiles objectAtIndex:page];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
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
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
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
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    UITabBarController *comicViewingTabBarController = [storyBoard instantiateViewControllerWithIdentifier:@"comic_reader_tab_bar_controller"];
    comicViewingTabBarController.selectedIndex = 1; //show library view controller
    [AppDelegate sharedAppDelegate].window.rootViewController = comicViewingTabBarController;

}

- (IBAction)previousAction:(id)sender {
    if (currentPage > 0) {
        currentPage --;
        [self gotoPage:currentPage];
    }
}

- (IBAction)nextAction:(id)sender {
    if (currentPage < comicFiles.count) {
        currentPage ++;
        [self gotoPage:currentPage];
    }
}

- (IBAction)tapOnViewAction:(id)sender {
    if (navigationBar.hidden) {
        [self showToolbars:YES];
    } else {
        [self hideToolbars:YES];
    }
}

#pragma mark - rotation
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self hideToolbars:NO];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self gotoPage:currentPage];
    [self showToolbars:YES];
}
@end
