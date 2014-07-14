//
//  ImageDownloader.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader()
@property NSMutableData *receivedData;
@property long long fileSize;
@property NSString *saveToFolder;
@property NSString *saveToFile;
@end

@implementation ImageDownloader
@synthesize urlConnection;
@synthesize imageURL;
@synthesize receivedData;
@synthesize fileSize;
@synthesize saveToFolder;
@synthesize saveToFile;

-(void)downloadImage:(NSString*)imgURL :(NSString*)toFolder{
    imageURL = imgURL;
    saveToFolder = toFolder;
    NSURL *url = [NSURL URLWithString:[[@"http://" stringByAppendingString:imgURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self startImmediately:NO];
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    receivedData = [NSMutableData new];
    fileSize = [(NSHTTPURLResponse*)response expectedContentLength];
    saveToFile = [saveToFolder stringByAppendingPathComponent:response.suggestedFilename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:saveToFile]) {
        [connection cancel];
        [self.delegate downloadOfImageFinished:YES :imageURL :saveToFile];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
    if ([self.delegate respondsToSelector:@selector(downloadOfImageProgressUpdated::)]){
        CGFloat progress = (float)receivedData.length / (float)fileSize;
//        NSLog(@"progress %f", progress);
        [self.delegate downloadOfImageProgressUpdated: progress:imageURL];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate downloadOfImageFinished:NO :imageURL :nil];
    NSLog(@"%@", error);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError *error;
    [receivedData writeToFile:saveToFile options:NSDataWritingAtomic error:&error];
    if (error){
        [self.delegate downloadOfImageFinished:NO :imageURL :nil];
        NSLog(@"%@", error);
    } else
        [self.delegate downloadOfImageFinished:YES :imageURL :saveToFile];
}

-(void)start {
    [urlConnection start];
}

-(void)stop {
    [urlConnection cancel];
}

-(NSUInteger)hash{
    return imageURL.hash;
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[self class]])
        return [[(ImageDownloader*)object imageURL] isEqualToString:self.imageURL];
    return NO;
}

@end
