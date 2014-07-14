//
//  XMLDownloader.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "XMLDownloader.h"

@interface XMLDownloader()<NSURLConnectionDataDelegate>
@property NSURLConnection *urlConnection;
@property NSMutableData *receivedData;
@property long long fileSize;
@end

@implementation XMLDownloader
@synthesize sinceDate;
@synthesize pageNumber;
@synthesize urlConnection;
@synthesize receivedData;
@synthesize fileSize;

-(void)downloadXML {
    NSString *storeHost = COMIC_LIST_HOST;
    //TODO: since date and page number are given, put them into the URL
    if (sinceDate || pageNumber) {
        if (sinceDate) {
        }
    }
    
    urlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:storeHost]] delegate:self];
    [urlConnection start];
}

-(void)cancel {
    if (urlConnection)
        [urlConnection cancel];
}

#pragma mark - NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    receivedData = [NSMutableData new];
    fileSize = [(NSHTTPURLResponse*)response expectedContentLength];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
    if ([self.delegate respondsToSelector:@selector(downloadProgressUpdated:)]) {
        [self.delegate downloadProgressUpdated:(receivedData.length / fileSize)];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate downloadOfXMLCompleted:NO :nil];
    NSLog(@"%@", error);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.delegate downloadOfXMLCompleted:YES :receivedData];
}
@end
