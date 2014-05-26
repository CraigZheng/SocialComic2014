//
//  BookCollectionViewController.m
//  SocialComic2014
//
//  Created by Craig on 10/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "BookCollectionViewController.h"
#import "AppDelegate.h"
#import "Comic.h"
#import "LocalComicSingleton.h"
#import "Toast+UIView.h"
#import "ComicViewingViewController.h"
#import "DACircularProgress/DACircularProgressView.h"
#import "Unzipper.h"
#import "ComicViewATPagingViewController.h"

@interface BookCollectionViewController ()<UnzipperDelegate>
@property NSMutableArray *comics;
@property AppDelegate *mAppDelegate;
@property DACircularProgressView *currentProgressView;
@property UIView *currentProgressBackgroundView;
@property LocalComicSingleton *comicSingleton;
@property Unzipper *unzipper;
@property Comic *selectedComic;
@end

@implementation BookCollectionViewController
@synthesize mAppDelegate;
@synthesize comics;
@synthesize comicSingleton;
@synthesize currentProgressView;
@synthesize unzipper;
@synthesize selectedComic;
@synthesize currentProgressBackgroundView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mAppDelegate = [AppDelegate sharedAppDelegate];
    unzipper = [[Unzipper alloc] initWithDelegate:self];
    [self.collectionView setContentInset:UIEdgeInsetsMake(20, 0, self.tabBarController.tabBar.frame.size.height, 0)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloaded:) name:@"ZIPDownloaded" object:nil];
    [self scanForComicFiles];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarItem.badgeValue = nil;
}

-(void)scanForComicFiles {
    comics = [NSMutableArray new];
    comicSingleton = [LocalComicSingleton getInstance];
    [comics addObjectsFromArray:comicSingleton.localComics];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewController datasource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return comics.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comic_cover_identifier" forIndexPath:indexPath];
    if (cell) {
        Comic *comic = [comics objectAtIndex:indexPath.row];
        UIImageView *coverImageView = (UIImageView*)[cell viewWithTag:1];
        UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
        //cover
        if (comic.cover)
        {
            coverImageView.image = comic.cover;
        } else {
            coverImageView.image = [UIImage imageNamed:@"NoImageAvailable.jpg"];
        }
        if (comic.unzipToFolder)
        {
            coverImageView.alpha = 1.0;
        } else {
            coverImageView.alpha = 0.5;
        }
        titleLabel.text = comic.name;
    }
    return cell;
}

#pragma mark - UICollectionViewControllerDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    selectedComic = [comics objectAtIndex:indexPath.row];
    if (selectedComic.unzipToFolder) {
        [self presentComicViewingControllerWithComic:selectedComic];
    } else {
        UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
        UIImageView *coverImageView = (UIImageView*)[selectedCell viewWithTag:1];
        CGFloat width = coverImageView.frame.size.width;
        DACircularProgressView *circularProgressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake((width - width / 2) / 2, (width - width / 2) / 2, width / 2, width / 2)];
        circularProgressView.trackTintColor = [UIColor clearColor];
        circularProgressView.progressTintColor = [UIColor blueColor];
        circularProgressView.thicknessRatio = 0.03f;
        circularProgressView.hidden = NO;
        circularProgressView.progress = 0;
        currentProgressView = circularProgressView;
        currentProgressBackgroundView = [[UIView alloc] initWithFrame:selectedCell.bounds];
        currentProgressBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        
        [selectedCell addSubview:currentProgressBackgroundView];
        [selectedCell addSubview:circularProgressView];
        [[AppDelegate sharedAppDelegate].window makeToast:@"Unzipping, please wait..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self unzip:selectedComic];
        });
    }
}

#pragma mark - Unzipping comic
-(BOOL)unzip:(Comic*)comic {
    if ([unzipper unzipComic:comic :mAppDelegate.unzipFolder]) {
        comic.unzipToFolder = [mAppDelegate.unzipFolder stringByAppendingPathComponent:comic.localZipFile.lastPathComponent.stringByDeletingPathExtension];
        return YES;
    }
    return NO;
}

#pragma mark - UnzipperDelegate
-(void)unzipUpdated:(int)progress :(int)filrProcessed :(unsigned long)numberOfFiles {
    if (currentProgressView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            currentProgressView.progress = (CGFloat)progress / 100.0;
        });
    }
    if (numberOfFiles == filrProcessed) {
        if (currentProgressView)
        {
            currentProgressBackgroundView.hidden = YES;
            [currentProgressBackgroundView removeFromSuperview];
            currentProgressView.hidden = YES;
            [currentProgressView removeFromSuperview];
        }
        if (selectedComic) {
            [self presentComicViewingControllerWithComic:selectedComic];
        }
    }
}

#pragma mark - present comic viewing controller with given comic
-(void)presentComicViewingControllerWithComic:(Comic*)comic {
    dispatch_async(dispatch_get_main_queue(), ^{
        ComicViewATPagingViewController *comicATPagingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"comic_view_at_paging_view_controller"];
        comicATPagingViewController.myComic = comic;
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"comic_viewing_navigation_controller"];
        [UIView transitionWithView:[AppDelegate sharedAppDelegate].window
                          duration:0.2
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            [AppDelegate sharedAppDelegate].window.rootViewController = navigationController;
                            [navigationController pushViewController:comicATPagingViewController animated:YES];
                            
                        }
                        completion:nil];

    });
}

#pragma mark - NSNotification handler - comic zip file downloaded
-(void)zipDownloaded:(NSNotification*)notification {
    if ([[notification.userInfo objectForKey:@"Success"] boolValue]) {
        [self scanForComicFiles];
    }
}
@end
