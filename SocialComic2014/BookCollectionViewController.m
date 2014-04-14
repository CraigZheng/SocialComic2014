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
    comicSingleton = [LocalComicSingleton getInstance];
    [self.collectionView setContentInset:UIEdgeInsetsMake(20, 0, 44, 0)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloaded:) name:@"ZIPDownloaded" object:nil];
    [self scanForComicFiles];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)scanForComicFiles {
    comics = [NSMutableArray new];
    [comicSingleton scanForLocalComics];
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
            coverImageView.image = [UIImage imageNamed:@"NoImageAvailable"];
        }
        titleLabel.text = comic.name;
    }
    return cell;
}

#pragma mark - UICollectionViewControllerDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Comic *selectedComic = [comics objectAtIndex:indexPath.row];
    //TODO: present the selectedComic
    [[[AppDelegate sharedAppDelegate] window] makeToast:[NSString stringWithFormat:@"You've selected %@, but this function is yet to implement", selectedComic.name]];
}

#pragma mark - NSNotification handler - comic zip file downloaded
-(void)zipDownloaded:(NSNotification*)notification {
    if ([[notification.userInfo objectForKey:@"Success"] boolValue]) {
        [self scanForComicFiles];
    }
}
@end
