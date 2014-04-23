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

@interface LocalComicSingleton()
@property AppDelegate *mAppDelegate;
@end

@implementation LocalComicSingleton
@synthesize mAppDelegate;

static LocalComicSingleton *_instance;

-(void)scanForLocalComics{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mAppDelegate.zipFileFolder error:nil];
    NSMutableArray *comics = [NSMutableArray new];
    for (NSString* file in files) {
        if ([file.pathExtension.lowercaseString isEqualToString:@"zip"]) {
            Comic *newComic = [self constructComicBasedOnZip:[mAppDelegate.zipFileFolder stringByAppendingPathComponent:file]];
            if (newComic)
                [comics addObject:newComic];
        }
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
        
        /*
         if (![[NSFileManager defaultManager] fileExistsAtPath:newComic.localDescriptionFile]) {
         newComic.localDescriptionFile = nil;
         }
         if (![[NSFileManager defaultManager] fileExistsAtPath:newComic.localCoverFile]) {
         newComic.localCoverFile = nil;
         }
         */
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
    if ([notification.userInfo objectForKey:@"Success"]) {
        [self scanForLocalComics];
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
