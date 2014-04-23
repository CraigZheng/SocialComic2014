//
//  ZIPCentre.h
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Comic.h"

@interface ZIPCentre : NSObject
@property AppDelegate *mAppDelegate;
@property NSMutableOrderedSet *downloadQueue;
@property NSMutableOrderedSet *downloadingZip;

-(void)downloadComic:(Comic*)comic;
-(BOOL)containsComic:(Comic*)comic;
-(void)stopAllDownloading;

+(id)getInstance;
@end
