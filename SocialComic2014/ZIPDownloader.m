//
//  ZIPDownloader.m
//  SocialComic2014
//
//  Created by Craig on 10/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ZIPDownloader.h"
#import "AppDelegate.h"

@interface ZIPDownloader()<NSURLConnectionDataDelegate>
@property NSURLConnection *urlConnection;
@property NSMutableData *receivedData;
@property long long fileSize;
@property AppDelegate *mAppDelegate;
@end

@implementation ZIPDownloader
@synthesize urlConnection;
@synthesize receivedData;
@synthesize fileSize;
@synthesize zipURL;
@synthesize saveToFile;
@synthesize saveToFolder;
@synthesize mAppDelegate;
@synthesize comic;

-(id)init{
    self = [super init];
    if (self) {
        mAppDelegate = [AppDelegate sharedAppDelegate];
    }
    return self;
}

-(void)downloadTXT:(NSString *)zipurl :(NSString *)toFolder{
    zipURL = zipurl;
    if (!comic) {
        comic = [Comic new];
        comic.zipFileURL = zipurl;
    }
    saveToFolder = toFolder;
    NSURL *url = [NSURL URLWithString:[[@"http://" stringByAppendingString:zipURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self startImmediately:NO];
    self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [urlConnection cancel];
    }];
}

-(void)downloadComic:(Comic *)com :(NSString *)toFolder{
    self.comic = com;
    [self downloadTXT:com.zipFileURL :toFolder];
}

-(void)start {
    if (urlConnection)
        [urlConnection start];
}

-(void)stop {
    if (urlConnection)
        [urlConnection cancel];
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
    if ([self.delegate respondsToSelector:@selector(ZIPDownloadProgressUpdated::)]) {
        [self.delegate ZIPDownloadProgressUpdated:zipURL :((CGFloat)receivedData.length / (CGFloat)fileSize)];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.delegate ZIPDownloaded:zipURL :NO :nil];
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error;
    [receivedData writeToFile:saveToFile options:NSDataWritingAtomic error:&error];
    if (error) {
        [self.delegate ZIPDownloaded:zipURL :NO :saveToFile];
    }
    [self.delegate ZIPDownloaded:zipURL :YES :saveToFile];
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    receivedData = [NSMutableData new];
    fileSize = response.expectedContentLength;
    saveToFile = [saveToFolder stringByAppendingPathComponent:response.suggestedFilename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:saveToFile]) {
        [self.delegate ZIPDownloaded:zipURL :YES :saveToFile];
        [urlConnection cancel];
        return;
    }
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[self class]]){
        BOOL equal = [[(ZIPDownloader*) object zipURL] isEqualToString:zipURL];
        return equal;
    }
    return NO;
}

-(NSUInteger)hash {
    return zipURL.hash;
}


@end
