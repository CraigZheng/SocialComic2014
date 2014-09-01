//
//  SocialComic2014Tests.m
//  SocialComic2014Tests
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BookmarkUtil.h"
#import "LocalComicSingleton.h"
#import "Comic.h"

@interface SocialComic2014Tests : XCTestCase

@end

@implementation SocialComic2014Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testBookmarkUtil
{
    LocalComicSingleton *localComics = [LocalComicSingleton getInstance];
    BookmarkUtil *bookmark = [BookmarkUtil getInstance];
    NSMutableArray *tempPage = [NSMutableArray new];
    NSMutableArray *orderOfAdding = [NSMutableArray new];
    for (Comic *comic in localComics.localComics) {
        int page = arc4random() % 100;
        [bookmark bookmarkPage:page forComic:comic];
        [tempPage addObject:[NSNumber numberWithInteger:page]];
        [orderOfAdding addObject:[NSNumber numberWithInteger:comic.hash]];
    }
    NSInteger index = 0;
    for (Comic *comic in localComics.localComics) {
        NSInteger page = [bookmark bookmarkForComic:comic];
        XCTAssertEqual(page, [[tempPage objectAtIndex:index] integerValue], @"recorded page does not match bookmarded page!");
        index++;
    }
    
    BookmarkUtil *newBookmark = [BookmarkUtil new];
    index = 0;
    for (Comic *comic in localComics.localComics) {
        NSInteger page = [newBookmark bookmarkForComic:comic];
        XCTAssertEqual(page, [[tempPage objectAtIndex:index] integerValue], @"recorded page does not match bookmarded page!");
        index++;
    }
    //test the order of adding
    for (int i = 0; i < orderOfAdding.count; i++) {
        Comic *recoverComic = [[newBookmark bookmarkedComics] objectAtIndex:i];
        NSLog(@"name: %@", recoverComic.name);
        XCTAssertEqual([[orderOfAdding objectAtIndex:i] integerValue], [recoverComic hash], @"hash not equal!");
    }
}

@end
