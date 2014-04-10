//
//  ZIPDownloader.h
//  SocialComic2014
//
//  Created by Craig on 10/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZIPDownloaderProtocol <NSObject>
-(void)ZIPDownloaded:(NSString*)zipURL :(BOOL)success :(NSString*)savePath;
@optional
-(void)ZIPDownloadProgressUpdated:(NSString*)zipURL :(CGFloat)progress;
@end
@interface ZIPDownloader : NSObject
@property NSString *zipURL;
@property NSString *saveToFolder;
@property NSString *saveToFile;

@property id<ZIPDownloaderProtocol> delegate;

-(void)downloadTXT:(NSString*)zipurl :(NSString*)toFolder;
-(void)start;
-(void)stop;
@end
