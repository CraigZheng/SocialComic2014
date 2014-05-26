//
//  Unzipper.m
//  SocialComic2014
//
//  Created by Craig on 8/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "Unzipper.h"
#import "ZipArchive.h"

@implementation Unzipper
@synthesize delegate;

-(id)initWithDelegate:(id<UnzipperDelegate>)del {
    self = [super init];
    if (self) {
        delegate = del;
    }
    return self;
}

-(Comic*)unzipComic:(Comic *)comic :(NSString *)toPath {
    ZipArchive* za = [[ZipArchive alloc] init];
    ZipArchiveProgressUpdateBlock progressBlock = ^ (int percentage, int filesProcessed, unsigned long numFiles) {
        if (delegate) {
            [delegate unzipUpdated:percentage :filesProcessed :numFiles];
        }
    };
    za.progressBlock = progressBlock;
    if( [za UnzipOpenFile:comic.localZipFile] && [za UnzipFileTo:toPath overWrite:YES]) {
        comic.unzipToFolder = [toPath stringByAppendingPathComponent:comic.localZipFile.lastPathComponent.stringByDeletingPathExtension];
        return comic;
    } else {
        comic.unzipToFolder = nil;
        
        return comic;
    }
}
@end
