//
//  TXTDownloader.h
//  SocialComic2014
//
//  Created by Craig on 10/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol TXTDownloaderDelegate<NSObject>
-(void)TXTDownloaded:(NSString*)txtURL :(BOOL)success :(NSString*)saveToFolder;
@end

@interface TXTDownloader : NSObject
@property id<TXTDownloaderDelegate> delegate;
@property NSString *txtURL;
@property NSString *saveToFolder;
@property NSString *saveToFile;

-(void)downloadTXT:(NSString*)txtURL :(NSString*)saveToFolder;
-(void)start;
-(void)stop;
@end
