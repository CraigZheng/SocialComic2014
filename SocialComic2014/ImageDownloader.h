//
//  ImageDownloader.h
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol ImageDownloaderDelegate<NSObject>
-(void)downloadOfImageFinished:(BOOL)success :(NSString*)imageURL :(NSString*)savePath;
@optional
-(void)downloadOfImageProgressUpdated:(CGFloat)progress :(NSString*)imageURL;
@end

@interface ImageDownloader : NSObject <NSURLConnectionDataDelegate>
@property NSString *imageURL;
@property id<ImageDownloaderDelegate> delegate;
@property NSURLConnection *urlConnection;


-(void)downloadImage:(NSString*)imgURL :(NSString*)toFolder;
-(void)start;
-(void)stop;
@end
