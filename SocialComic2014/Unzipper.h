//
//  Unzipper.h
//  SocialComic2014
//
//  Created by Craig on 8/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comic.h"

@protocol UnzipperDelegate <NSObject>
-(void)unzipUpdated:(int)progress :(int)filrProcessed :(unsigned long)numberOfFiles;

@end
@interface Unzipper : NSObject
@property id<UnzipperDelegate> delegate;

-(id)initWithDelegate:(id<UnzipperDelegate>)del;
-(Comic*)unzipComic:(Comic*)comic :(NSString*)toPath;
@end
