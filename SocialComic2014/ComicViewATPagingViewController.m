//
//  ComicViewATPagingViewController.m
//  SocialComic2014
//
//  Created by Craig on 16/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ComicViewATPagingViewController.h"
#import "ComicViewingViewController.h"

@interface ComicViewATPagingViewController ()
@property NSMutableArray *comicPages;
@end

@implementation ComicViewATPagingViewController
@synthesize myComic;
@synthesize comicPages;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    comicPages = [NSMutableArray new];
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:myComic.unzipToFolder error:nil]) {
        [comicPages addObject:[myComic.unzipToFolder stringByAppendingPathComponent:file]];
    }
}

-(NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView {
    return comicPages.count;
}

-(UIView *)viewForPageInPagingView:(ATPagingView *)pagingView atIndex:(NSInteger)index {
    ComicViewingViewController *comicViewingViewController = [[ComicViewingViewController alloc] initWithNibName:@"ComicViewingViewController" bundle:[NSBundle mainBundle]];
    NSString *file = [comicPages objectAtIndex:index];
    comicViewingViewController.comicFile = file;
    return comicViewingViewController.view;
}
@end
