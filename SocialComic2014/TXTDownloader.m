//
//  TXTDownloader.m
//  SocialComic2014
//
//  Created by Craig on 10/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "TXTDownloader.h"

@interface TXTDownloader() <NSURLConnectionDataDelegate>
@property NSURLConnection *urlConnection;
@property NSMutableData *receivedData;
@end

@implementation TXTDownloader
@synthesize urlConnection;
@synthesize txtURL;
@synthesize saveToFile;
@synthesize saveToFolder;
@synthesize receivedData;

-(void)downloadTXT:(NSString *)txturl :(NSString *)savetofolder{
    txtURL = txturl;
    saveToFolder = savetofolder;
    NSURL *url = [NSURL URLWithString:[[@"http://" stringByAppendingString:txtURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self startImmediately:NO];
}

-(void)start{
    if (urlConnection)
        [urlConnection start];
}

-(void)stop{
    if (urlConnection) {
        [urlConnection cancel];
    }
}

#pragma mark - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    [self.delegate TXTDownloaded:txtURL :NO :nil];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    saveToFile = [saveToFolder stringByAppendingPathComponent:response.suggestedFilename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:saveToFile]) {
        [self.delegate TXTDownloaded:txtURL :YES :saveToFile];
        [connection cancel];
        return;
    }
    receivedData = [NSMutableData new];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError *error;
    [receivedData writeToFile:saveToFile options:NSDataWritingAtomic error:&error];
    if (error)
        [self.delegate TXTDownloaded:txtURL :NO :saveToFile];
    else
        [self.delegate TXTDownloaded:txtURL :YES :saveToFile];
}
@end
