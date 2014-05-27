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

@end

@implementation ComicPagingScrollViewController
@synthesize scrollView;
@synthesize myComic;
@synthesize comicFiles;
@synthesize currentPage;
@synthesize viewControllers;
@synthesize topToolbar;
@synthesize bottomToolbar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    topToolbar.hidden = YES;
    bottomToolbar.hidden = YES;
    self.view.frame = [UIScreen mainScreen].bounds;

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
    [[AppDelegate sharedAppDelegate] doSingleViewShowAnimation:topToolbar :kCATransitionFromBottom :0.3];
    [[AppDelegate sharedAppDelegate] doSingleViewShowAnimation:bottomToolbar :kCATransitionFromTop :0.3];
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
}


-(void)setupToolbars {
    topToolbar.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, topToolbar.frame.size.height);
    bottomToolbar.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.size.height - bottomToolbar.frame.size.height, scrollView.frame.size.width, topToolbar.frame.size.height);
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
@end
