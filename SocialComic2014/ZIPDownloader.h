//
//  ZIPDownloader.h
//  SocialComic2014
//
//  Created by Craig on 10/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comic.h"
@class ZIPDownloader;
@protocol ZIPDownloaderProtocol <NSObject>
-(void)ZIPDownloaded:(ZIPDownloader*)downloader :(BOOL)success :(NSString*)savePath;
@optional
-(void)ZIPDownloadProgressUpdated:(ZIPDownloader*)downloader :(NSString*)zipURL :(CGFloat)progress;
@end
@interface ZIPDownloader : NSObject
@property NSString *zipURL;
@property NSString *saveToFolder;
@property NSString *saveToFile;
@property NSString *unzipToFolder;
@property Comic *comic;
@property UIBackgroundTaskIdentifier backgroundTaskID;
@property id<ZIPDownloaderProtocol> delegate;

-(void)downloadTXT:(NSString*)zipurl :(NSString*)toFolder :(NSString*)unzipToFolder;
-(void)downloadComic:(Comic*)comic :(NSString*)toFolder :(NSString*)unzipToFolder;
-(void)start;
-(void)stop;

@end
