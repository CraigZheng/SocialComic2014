//
//  BookmarkUtil.h
//  SocialComic2014
//
//  Created by Craig Zheng on 1/09/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comic.h"

@interface BookmarkUtil : NSObject

@property (nonatomic) NSArray *bookmarkedComics;

-(void)bookmarkPage:(NSInteger)page forComic:(Comic*)comic;
-(NSInteger)bookmarkForComic:(Comic*)comic;
-(void)removeBookmarkForComic:(Comic*)comic;

+(id)getInstance;
@end
