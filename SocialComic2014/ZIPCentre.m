//
//  ZIPCentre.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ZIPCentre.h"
#import "ZIPDownloader.h"

@interface ZIPCentre()<ZIPDownloaderProtocol>
@property NSMutableOrderedSet *downloadQueue;
@property NSMutableOrderedSet *downloadingZip;
@end
@implementation ZIPCentre
@synthesize mAppDelegate;
@synthesize downloadingZip;
@synthesize downloadQueue;



-(void)downloadComic:(Comic *)comic {
    if ([downloadQueue containsObject:comic])
        return;
    if (downloadingZip.count < 3) {
        ZIPDownloader *downloader = [self createDownloaderWithURL:comic.zipFileURL];
        if ([downloadingZip containsObject:downloader]){
            return;
        }
        [downloader start];
        [downloadingZip addObject:downloader];
    } else {
        [downloadQueue addObject:comic];
    }
}

-(ZIPDownloader*)createDownloaderWithURL:(NSString*)url {
    ZIPDownloader *downloader = [ZIPDownloader new];
    downloader.delegate = self;
    [downloader downloadTXT:url :mAppDelegate.zipFileFolder];
    return downloader;
}

-(void)activateNextDownload {
    if (downloadingZip.count < 3 && downloadQueue.count > 0) {
        NSString *imgURL = [downloadQueue firstObject];
        [downloadQueue removeObjectAtIndex:0];
        ZIPDownloader *downloader = [self createDownloaderWithURL:imgURL];
        [downloader start];
        [downloadingZip addObject:downloader];
    } else {
        NSLog(@"no more downloads!");
        [self stopAllDownloading];
    }
}

-(void)stopAllDownloading {
    for (ZIPDownloader *downloader in downloadingZip) {
        [downloader stop];
    }
    [downloadingZip removeAllObjects];
    [downloadQueue removeAllObjects];
}

#pragma mark - ZIPDownloaderDelegate
-(void)ZIPDownloaded:(NSString *)zipURL :(BOOL)success :(NSString *)savePath{
    NSDictionary *userInfo;
    if (success)
        userInfo = [NSDictionary dictionaryWithObjects:@[zipURL, savePath, [NSNumber numberWithBool:success]] forKeys:@[@"ZIPURL", @"SavePath", @"Success"]];
    else
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:success] forKey:@"Success"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZIPDownloaded" object:nil userInfo:userInfo];
    //remove the just finished downloader
    if (zipURL) {
        ZIPDownloader *downloader = [self createDownloaderWithURL:zipURL];
        [downloadingZip removeObject:downloader];
    }
    [self activateNextDownload];
}

-(void)ZIPDownloadProgressUpdated:(NSString *)zipURL :(CGFloat)progress {
    if (zipURL || progress) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[zipURL, [NSNumber numberWithFloat:progress]] forKeys:@[@"ZIPURL", @"Progress"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZipDownloadProgressUpdate" object:self userInfo:userInfo];
    }
}

#pragma mark - singleton initialiser
-(id)init {
    self = [super init];
    if (self) {
        mAppDelegate = [AppDelegate sharedAppDelegate];
        downloadQueue = [NSMutableOrderedSet new];
        downloadingZip = [NSMutableOrderedSet new];
    }
    return self;
}

+ (id)getInstance {
    static ZIPCentre *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [[self alloc] init];
        }
    }
    return sharedMyManager;
}
@end
