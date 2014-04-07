//
//  ComicStoreViewController.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ComicStoreViewController.h"
#import "XMLDownloader.h"
#import "XMLProsessor.h"

@interface ComicStoreViewController ()<XMLDownloaderDelegate>

@end

@implementation ComicStoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    XMLDownloader *xmlDownloader = [XMLDownloader new];
    xmlDownloader.delegate = self;
    [xmlDownloader downloadXML];
}

-(void)downloadOfXMLCompleted:(BOOL)success :(NSData *)xmlData{
    if (success){
        NSArray *comics = [[XMLProsessor new] parseXML:xmlData];
        NSLog(@"size %d", comics.count);
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
