//
//  BookmarkUtil.m
//  SocialComic2014
//
//  Created by Craig Zheng on 1/09/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#define BOOKMARK_FILE_NAME @"BOOKMARK.DAT"
#define BOOKMARK_KEY_NAME @"KEYFILE.DAT"

#import "BookmarkUtil.h"
#import "LocalComicSingleton.h"

@interface BookmarkUtil ()
@property NSMutableDictionary *bookmarks;
@property NSMutableArray *orderedKey;
@end

@implementation BookmarkUtil
@synthesize bookmarks;
@synthesize bookmarkedComics;
@synthesize orderedKey;

-(NSArray *)bookmarkedComics {
    NSMutableArray *tempArray = [NSMutableArray new];
    for (NSNumber *hashKey in orderedKey) {
        for (Comic *localComic in [[LocalComicSingleton getInstance] localComics]) {
            if (localComic.hash == hashKey.integerValue) {
                [tempArray addObject:localComic];
            }
        }
    }
    return tempArray;
}

-(void)bookmarkPage:(NSInteger)page forComic:(Comic *)comic {
    if (!comic)
        return;
    NSNumber *pageNumber = [NSNumber numberWithInteger:page];
    NSNumber *hashKey = [NSNumber numberWithInteger:comic.hash];
    [bookmarks setObject:pageNumber forKey:hashKey];
    [orderedKey removeObject:[NSNumber numberWithInteger:comic.hash]];
    [orderedKey addObject:[NSNumber numberWithInteger:comic.hash]];
    [self saveBookmark];
    [self saveKey];
}

-(void)removeBookmarkForComic:(Comic *)comic {
    [bookmarks setObject:[NSNull null] forKey:[NSNumber numberWithInteger:comic.hash]];
    [orderedKey removeObject:[NSNumber numberWithInteger:comic.hash]];
    [self saveBookmark];
    [self saveKey];
}

-(NSInteger)bookmarkForComic:(Comic *)comic {
    NSNumber *page = [bookmarks objectForKey:[NSNumber numberWithInteger:comic.hash]];
    if (page)
        return [page integerValue];
    return 0;
}

-(void)saveBookmark {
    NSString* path = [NSSearchPathForDirectoriesInDomains(
                                                          NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:BOOKMARK_FILE_NAME];
    [NSKeyedArchiver archiveRootObject:self.bookmarks toFile:filePath];
}

-(NSMutableDictionary*)recoverBookmark {
    NSString* path = [NSSearchPathForDirectoriesInDomains(
                                                          NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:BOOKMARK_FILE_NAME];
    @try {
        NSMutableDictionary *savedBookmark = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (savedBookmark) {
            return savedBookmark;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return nil;
}

-(NSMutableArray*)recoverOrderedKey {
    NSString* path = [NSSearchPathForDirectoriesInDomains(
                                                          NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *keyPath = [path stringByAppendingPathComponent:BOOKMARK_KEY_NAME];
    @try {
        NSMutableArray *tempKey = [NSKeyedUnarchiver unarchiveObjectWithFile:keyPath];
        if (tempKey)
            return tempKey;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return nil;
}

-(void)saveKey {
    NSString* path = [NSSearchPathForDirectoriesInDomains(
                                                          NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *keyPath = [path stringByAppendingPathComponent:BOOKMARK_KEY_NAME];
    [NSKeyedArchiver archiveRootObject:orderedKey toFile:keyPath];
}

-(void)restoreBookmarks {
    bookmarks = [NSMutableDictionary new];
    if ([self recoverBookmark]) {
        bookmarks = [self recoverBookmark];
    }
    orderedKey = [NSMutableArray new];
    if ([self recoverOrderedKey])
        orderedKey = [self recoverOrderedKey];
}

-(id)init {
    self = [super init];
    if (self) {
        //recover recorded bookmark
        [self restoreBookmarks];
    }
    return self;
}

+ (id)getInstance {
    static BookmarkUtil *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [[self alloc] init];
        }
    }
    return sharedMyManager;
}
@end
