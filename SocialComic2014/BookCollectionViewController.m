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

@interface BookCollectionViewController ()
@property NSMutableArray *comics;
@property AppDelegate *mAppDelegate;
@property LocalComicSingleton *comicSingleton;
@end

@implementation BookCollectionViewController
@synthesize mAppDelegate;
@synthesize comics;
@synthesize comicSingleton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mAppDelegate = [AppDelegate sharedAppDelegate];
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
    Comic *selectedComic = [comics objectAtIndex:indexPath.row];
    if (selectedComic.unzipToFolder) {
        [self presentComicViewingControllerWithComic:selectedComic];
    } else {
        UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
        DACircularProgressView *circularProgressView = [[DACircularProgressView alloc] initWithFrame:selectedCell.frame];
        circularProgressView.indeterminate = 1;
        [selectedCell addSubview:circularProgressView];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if ([self unzip:selectedComic]) {
                if (selectedComic.unzipToFolder) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentComicViewingControllerWithComic:selectedComic]; 
                    });
                }
            }
        });
    }
}

#pragma mark - Unzipping comic
-(BOOL)unzip:(Comic*)comic {
    if ([[Unzipper new] unzipComic:comic :mAppDelegate.unzipFolder]) {
        comic.unzipToFolder = [mAppDelegate.unzipFolder stringByAppendingPathComponent:comic.name];
        return YES;
    }
    return NO;
}

#pragma mark - present comic viewing controller with given comic
-(void)presentComicViewingControllerWithComic:(Comic*)comic {
    ComicViewingViewController *comicViewingViewController = [[ComicViewingViewController alloc] initWithNibName:@"ComicViewingViewController" bundle:[NSBundle mainBundle]];
    comicViewingViewController.myComic = comic;

    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"comic_viewing_navigation_controller"];
    [UIView transitionWithView:[AppDelegate sharedAppDelegate].window
                      duration:0.2
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        [AppDelegate sharedAppDelegate].window.rootViewController = navigationController;
                        [navigationController pushViewController:comicViewingViewController animated:YES];
                    }
                    completion:nil];

}

#pragma mark - NSNotification handler - comic zip file downloaded
-(void)zipDownloaded:(NSNotification*)notification {
    if ([[notification.userInfo objectForKey:@"Success"] boolValue]) {
        [self scanForComicFiles];
    }
}
@end
