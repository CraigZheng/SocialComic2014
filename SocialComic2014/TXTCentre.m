//
//  TXTCentre.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "TXTCentre.h"
#import "TXTDownloader.h"
#import "AppDelegate.h"

@interface TXTCentre () <TXTDownloaderDelegate>
@property AppDelegate *mAppDelegate;
@property NSMutableOrderedSet *downloadingQueue;
@end

@implementation TXTCentre
@synthesize mAppDelegate;
@synthesize downloadingQueue;

-(id)init{
    self = [super init];
    if (self) {
        mAppDelegate = [AppDelegate sharedAppDelegate];
        downloadingQueue = [NSMutableOrderedSet new];
    }
    return self;
}

-(void)downloadTXT:(NSString *)txtURL {
    TXTDownloader *downloader = [TXTDownloader new];
    [downloader downloadTXT:txtURL :mAppDelegate.descriptionFileFolder];
    downloader.delegate = self;
    [downloader start];
    [downloadingQueue addObject:downloader];
}

#pragma mark - TXTDownloaderDelegate
-(void)TXTDownloaded:(NSString *)txtURL :(BOOL)success :(NSString *)savePath{
    NSDictionary *userInfo;
    if (success) {
        userInfo = [NSDictionary dictionaryWithObjects:@[txtURL, [NSNumber numberWithBool:success], savePath] forKeys:@[@"TXTURL", @"Success", @"SavePath"]];
    } else {
        userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:success]] forKeys:@[ @"Success"]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TXTDownloaded" object:self userInfo:userInfo];
}
@end
