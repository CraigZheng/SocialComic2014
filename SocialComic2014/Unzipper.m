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
-(Comic*)unzipComic:(Comic *)comic :(NSString *)toPath {
    ZipArchive* za = [[ZipArchive alloc] init];
    if( [za UnzipOpenFile:comic.localZipFile] && [za UnzipFileTo:toPath overWrite:YES]) {
        comic.unzipToFolder = [toPath stringByAppendingPathComponent:comic.localZipFile.lastPathComponent.stringByDeletingPathExtension];
        return comic;
    } else {
        comic.unzipToFolder = nil;
        return comic;
    }
}
@end
