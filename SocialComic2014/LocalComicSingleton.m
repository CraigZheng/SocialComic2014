//
//  LocalComicSingleton.m
//  SocialComic2014
//
//  Created by Craig on 11/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "LocalComicSingleton.h"
#import "AppDelegate.h"
#import "Comic.h"
#import "ZIPDownloader.h"

@interface LocalComicSingleton()
@property AppDelegate *mAppDelegate;
@property NSArray *unzippedComics;
@end

@implementation LocalComicSingleton
@synthesize mAppDelegate;
@synthesize unzippedComics;

static LocalComicSingleton *_instance;

-(void)scanForLocalComics{
    unzippedComics = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mAppDelegate.unzipFolder error:nil];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mAppDelegate.zipFileFolder error:nil];
    NSMutableArray *comics = [NSMutableArray new];
    for (NSString* file in files) {
        if ([file.pathExtension.lowercaseString isEqualToString:@"zip"]) {
            Comic *newComic = [self constructComicBasedOnZip:[mAppDelegate.zipFileFolder stringByAppendingPathComponent:file]];
            if (newComic)
                [comics addObject:newComic];
        }
    }
    
    @try {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        comics = [NSMutableArray arrayWithArray:[comics sortedArrayUsingDescriptors:@[sort]]];
    }
    @catch (NSException *exception) {
        
    }

    self.localComics = comics;
}

-(BOOL)containsComic:(Comic *)comic {
    for (Comic* localComic in self.localComics) {
        NSString* comicName = localComic.zipFileURL ? localComic.zipFileURL.lastPathComponent : localComic.localZipFile.lastPathComponent;
        if ([comicName isEqualToString:comic.zipFileURL.lastPathComponent] || [comicName isEqualToString:comic.localZipFile.lastPathComponent])
            return YES;
    }
    return NO;
}

-(Comic*)constructComicBasedOnZip:(NSString*)zipFile {
    if (zipFile && [zipFile.pathExtension.lowercaseString isEqualToString:@"zip"]) {
        Comic *newComic = [Comic new];
        newComic.localZipFile = zipFile;
        NSString *fileName = [newComic.localZipFile.lastPathComponent stringByDeletingPathExtension];
        newComic.localDescriptionFile = [[mAppDelegate.descriptionFileFolder stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"txt"];
        newComic.localCoverFile = [[mAppDelegate.coverImageFolder stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"jpg"];
        for (NSString *comicFolder in unzippedComics) {
            if ([comicFolder isEqualToString:fileName])
            {
                newComic.unzipToFolder = [mAppDelegate.unzipFolder stringByAppendingPathComponent:comicFolder];
                break;
            }
        }
        return newComic;
    }
    return nil;
}

-(id)init {
    self = [super init];
    if (self) {
        mAppDelegate = [AppDelegate sharedAppDelegate];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipDownloaded:) name:@"ZIPDownloaded" object:nil];
        [self scanForLocalComics];
    }
    return self;
}

#pragma mark - notification handlers
-(void)zipDownloaded:(NSNotification*)notification {
    if ([[notification.userInfo objectForKey:@"Success"] boolValue]) {
        ZIPDownloader *downloader = [notification.userInfo objectForKey:@"ZIPDownloader"];
        if (downloader.comic) {
            [self scanForLocalComics];
        }
    }
}

+ (id)getInstance {
    static LocalComicSingleton *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [[self alloc] init];
        }
    }
    return sharedMyManager;
}
@end
