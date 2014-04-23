//
//  LocalComicSingleton.h
//  SocialComic2014
//
//  Created by Craig on 11/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Comic;
@interface LocalComicSingleton : NSObject
@property NSArray* localComics;

+(id)getInstance;

-(void)scanForLocalComics;
-(BOOL)containsComic:(Comic*)comic;
@end
