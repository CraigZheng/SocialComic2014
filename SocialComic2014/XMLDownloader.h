//
//  XMLDownloader.h
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "Constants.h"
#import <Foundation/Foundation.h>
@protocol XMLDownloaderDelegate <NSObject>
-(void)downloadOfXMLCompleted:(BOOL)success :(NSData*)xmlData;
@optional
-(void)downloadProgressUpdated:(CGFloat)progress;
@end

@interface XMLDownloader : NSObject
@property NSInteger pageNumber;
@property NSDate *sinceDate;
@property id<XMLDownloaderDelegate> delegate;

-(void)downloadXML;
-(void)cancel;
@end
