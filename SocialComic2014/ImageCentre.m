//
//  ImageDownloader.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ImageCentre.h"
#import "ImageDownloader.h"
#import "AppDelegate.h"

@interface ImageCentre() <ImageDownloaderDelegate>
@property NSURLConnection *urlConnection;
@property NSMutableOrderedSet *downloadQueue;
@property NSMutableOrderedSet *downloadingImage;
@property NSString *libraryFolder;
@property AppDelegate *mAppDelegate;
@end

@implementation ImageCentre
@synthesize urlConnection;
@synthesize downloadingImage;
@synthesize downloadQueue;
@synthesize libraryFolder;
@synthesize mAppDelegate;

-(void)downloadImageWithURL:(NSString *)imgURL {
    if ([downloadQueue containsObject:imgURL])
        return;
    if (downloadingImage.count < 3) {
        ImageDownloader *downloader = [self createImageDownloaderWithURL:imgURL];
        if ([downloadingImage containsObject:downloader]){
            return;
        }
        [downloader start];
        [downloadingImage addObject:downloader];
    } else {
        [downloadQueue addObject:imgURL];
    }
}

#pragma mark - ImageDownloaderDelegate
-(void)downloadOfImageFinished:(BOOL)success :(NSString *)imageURL :(NSString*)savePath {
    NSDictionary *userInfo;
    if (success)
        userInfo = [NSDictionary dictionaryWithObjects:@[imageURL, savePath, [NSNumber numberWithBool:success]] forKeys:@[@"ImageURL", @"SavePath", @"Success"]];
    else
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:success] forKey:@"Success"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDownloaded" object:nil userInfo:userInfo];
    //remove the just finished downloader
    if (imageURL) {
        ImageDownloader *imgDownloader = [self createImageDownloaderWithURL:imageURL];
        [downloadingImage removeObject:imgDownloader];
    }
    [self activateNextDownload];
}

-(void)downloadOfImageProgressUpdated:(CGFloat)progress :(NSString *)imageURL{
   // NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[imageURL, [NSNumber numberWithFloat:progress]] forKeys:@[@"ImageURL", @"Progress"]];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDownloadProgressUpdated" object:nil userInfo:userInfo];
}

-(void)activateNextDownload {
    if (downloadingImage.count < 3 && downloadQueue.count > 0) {
        NSString *imgURL = [downloadQueue firstObject];
        [downloadQueue removeObjectAtIndex:0];
        ImageDownloader *imgDownloader = [self createImageDownloaderWithURL:imgURL];
        [imgDownloader start];
        [downloadingImage addObject:imgDownloader];
    } else {
        NSLog(@"no more downloads!");
        [self stopAllDownloading];
    }
}

-(ImageDownloader*)createImageDownloaderWithURL:(NSString*)imgURL {
    ImageDownloader *imgDownloader = [ImageDownloader new];
    imgDownloader.delegate = self;
    [imgDownloader downloadImage:imgURL :mAppDelegate.coverImageFolder];
    return imgDownloader;
}

-(void)stopDownloadingOfURL:(NSString *)imgURL{
    for (ImageDownloader *downloader in downloadingImage) {
        if ([downloader.imageURL isEqualToString:imgURL])
            [downloader stop];
    }
    [downloadQueue removeObject:imgURL];
}

-(void)stopAllDownloading {
    for (ImageDownloader *downloader in downloadingImage) {
        [downloader stop];
    }
    [downloadingImage removeAllObjects];
    [downloadQueue removeAllObjects];
}

#pragma mark - singleton initialiser
-(id)init{
    self = [super init];
    if (self){
        downloadQueue = [NSMutableOrderedSet new];
        downloadingImage = [NSMutableOrderedSet new];
        libraryFolder = [NSSearchPathForDirectoriesInDomains(
                                                             NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        mAppDelegate = [AppDelegate sharedAppDelegate];
    }
    return self;
}

+ (id)getInstance {
    static ImageCentre *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [[self alloc] init];
        }
    }
    return sharedMyManager;
}
@end
