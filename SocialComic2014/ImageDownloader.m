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
@end

@implementation ImageDownloader
@synthesize urlConnection;
@synthesize imageURL;
@synthesize receivedData;
@synthesize fileSize;
@synthesize saveToFolder;

-(void)downloadImage:(NSString*)imgURL :(NSString*)toFolder{
    imageURL = imgURL;
    saveToFolder = toFolder;
    urlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"http://" stringByAppendingString:imgURL]]] delegate:self];
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    receivedData = [NSMutableData new];
    fileSize = [(NSHTTPURLResponse*)response expectedContentLength];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
    if ([self.delegate respondsToSelector:@selector(downloadOfImageProgressUpdated::)]){
        [self.delegate downloadOfImageProgressUpdated:receivedData.length / fileSize :imageURL];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate downloadOfImageFinished:NO :imageURL :nil];
    NSLog(@"%@", error);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *saveToFile = [saveToFolder stringByAppendingPathComponent:imageURL.lastPathComponent];
    NSError *error;
    [receivedData writeToFile:saveToFile options:NSDataWritingAtomic error:&error];
    if (error){
        [self.delegate downloadOfImageFinished:NO :imageURL :nil];
        NSLog(@"%@", error);
    } else
        [self.delegate downloadOfImageFinished:YES :imageURL :saveToFolder];
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
