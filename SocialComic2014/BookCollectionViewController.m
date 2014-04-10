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

@interface BookCollectionViewController ()
@property NSMutableArray *comics;
@property AppDelegate *mAppDelegate;
@end

@implementation BookCollectionViewController
@synthesize mAppDelegate;
@synthesize comics;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mAppDelegate = [AppDelegate sharedAppDelegate];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scanForComicFiles];
    [self.collectionView reloadData];
}

-(void)scanForComicFiles {
    comics = [NSMutableArray new];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mAppDelegate.zipFileFolder error:nil];
    for (NSString* file in files) {
        if ([file.pathExtension.lowercaseString isEqualToString:@"zip"]) {
            Comic *newComic = [self constructComicBasedOnZip:[mAppDelegate.zipFileFolder stringByAppendingPathComponent:file]];
            if (newComic)
                [comics addObject:newComic];
        }
    }
}

-(Comic*)constructComicBasedOnZip:(NSString*)zipFile {
    if (zipFile && [zipFile.pathExtension.lowercaseString isEqualToString:@"zip"]) {
        Comic *newComic = [Comic new];
        newComic.localZipFile = zipFile;
        NSString *fileName = [newComic.localZipFile.lastPathComponent stringByDeletingPathExtension];
        newComic.localDescriptionFile = [[mAppDelegate.descriptionFileFolder stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"txt"];
        newComic.localCoverFile = [[mAppDelegate.coverImageFolder stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"jpg"];

        /*
        if (![[NSFileManager defaultManager] fileExistsAtPath:newComic.localDescriptionFile]) {
            newComic.localDescriptionFile = nil;
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:newComic.localCoverFile]) {
            newComic.localCoverFile = nil;
        }
         */
        return newComic;
    }
    return nil;
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
@end
