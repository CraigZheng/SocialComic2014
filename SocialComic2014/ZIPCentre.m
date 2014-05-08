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
@end
@implementation ZIPCentre
@synthesize mAppDelegate;
@synthesize downloadingZip;
@synthesize downloadQueue;



-(void)downloadComic:(Comic *)comic {
    if ([downloadQueue containsObject:comic])
        return;
    if (downloadingZip.count < 3) {
        ZIPDownloader *downloader = [self createDownloaderWithComic:comic];
        if ([downloadingZip containsObject:downloader]){
            return;
        }
        [downloader start];
        [downloadingZip addObject:downloader];
    } else {
        [downloadQueue addObject:comic];
    }
}

-(void)stopDownloadingComic:(Comic *)comic{
    for (ZIPDownloader* downloader in downloadingZip) {
        if ([downloader.zipURL isEqualToString:comic.zipFileURL])
        {
            [downloader stop];
            [downloadingZip removeObject:downloader];
            break;
        }
    }
    [downloadQueue removeObject:comic];
    [self activateNextDownload];
}

-(BOOL)containsComic:(Comic *)comic{
    ZIPDownloader *downloader = [self createDownloaderWithComic:comic];
    if ([downloadingZip containsObject:downloader] || [downloadQueue containsObject:comic])
        return YES;
    return NO;
}

-(ZIPDownloader*)createDownloaderWithComic:(Comic*)comic {
    ZIPDownloader *downloader = [ZIPDownloader new];
    downloader.delegate = self;
    [downloader downloadComic:comic :mAppDelegate.zipFileFolder :mAppDelegate.unzipFolder];
    return downloader;
}

-(ZIPDownloader*)createDownloaderWithURL:(NSString*)zipUrl {
    ZIPDownloader *downloader = [ZIPDownloader new];
    [downloader downloadTXT:zipUrl :mAppDelegate.zipFileFolder :mAppDelegate.unzipFolder];
    return downloader;
}

-(void)activateNextDownload {
    if (downloadingZip.count < 3 && downloadQueue.count > 0) {
        Comic *comic = [downloadQueue firstObject];
        [downloadQueue removeObjectAtIndex:0];
        ZIPDownloader *downloader = [self createDownloaderWithComic:comic];
        [downloader start];
        [downloadingZip addObject:downloader];
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
-(void)ZIPDownloaded:(ZIPDownloader *)downloader :(BOOL)success :(NSString *)savePath{
    NSDictionary *userInfo;
    if (success) {
        userInfo = [NSDictionary dictionaryWithObjects:@[downloader, savePath, [NSNumber numberWithBool:success]] forKeys:@[@"ZIPDownloader", @"SavePath", @"Success"]];
    }
    else
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:success] forKey:@"Success"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZIPDownloaded" object:nil userInfo:userInfo];
    //remove the just finished downloader
    [downloadingZip removeObject:downloader];
    [self activateNextDownload];
}

-(void)ZIPDownloadProgressUpdated:(ZIPDownloader*)downloader :(NSString *)zipURL :(CGFloat)progress {
    if (zipURL || progress) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[downloader, zipURL, [NSNumber numberWithFloat:progress]] forKeys:@[@"ZIPDownloader", @"ZIPURL", @"Progress"]];
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
