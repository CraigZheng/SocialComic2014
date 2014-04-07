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
@end

@implementation ImageDownloader
@synthesize urlConnection;
@synthesize imageURL;
@synthesize receivedData;
@synthesize fileSize;

-(void)downloadImage:(NSString*)imgURL {
    self.imageURL = imgURL;
    urlConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgURL]] delegate:self startImmediately:YES];
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
    [self.delegate downloadOfImageFinished:NO :nil :nil];
    NSLog(@"%@", error);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}
@end
