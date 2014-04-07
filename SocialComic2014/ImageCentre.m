//
//  ImageDownloader.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ImageCentre.h"
#import "ImageDownloader.h"

@interface ImageCentre() <ImageDownloaderDelegate>
@property NSURLConnection *urlConnection;
@property NSMutableOrderedSet *downloadQueue;
@property NSMutableOrderedSet *downloadingImage;
@end

@implementation ImageCentre
@synthesize urlConnection;
@synthesize downloadingImage;
@synthesize downloadQueue;

-(id)init{
    self = [super init];
    if (self){
        downloadQueue = [NSMutableOrderedSet new];
        downloadingImage = [NSMutableOrderedSet new];
    }
    return self;
}
-(void)downloadImageWithURL:(NSString *)imgURL {
    ImageDownloader *imgDownloader = [ImageDownloader new];
    imgDownloader.delegate = self;
    [imgDownloader downloadImage:imgURL];
    
}

-(void)downloadOfImageFinished:(BOOL)success :(NSString *)imageURL {
    if (success) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[imageURL] forKeys:@[@"ImageURL"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageDownloaded" object:nil userInfo:userInfo];
    }
}
@end
