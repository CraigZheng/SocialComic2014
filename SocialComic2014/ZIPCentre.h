//
//  ZIPCentre.h
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"


@interface ZIPCentre : NSObject
@property AppDelegate *mAppDelegate;

-(void)downloadZIP:(NSString*)zipURL;

-(void)stopAllDownloading;
@end
