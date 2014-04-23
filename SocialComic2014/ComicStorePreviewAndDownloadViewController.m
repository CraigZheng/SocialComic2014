//
//  ComicStorePreviewAndDownloadViewController.m
//  SocialComic2014
//
//  Created by Craig on 23/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ComicStorePreviewAndDownloadViewController.h"

@interface ComicStorePreviewAndDownloadViewController ()

@end

@implementation ComicStorePreviewAndDownloadViewController
@synthesize comicCoverPreview;
@synthesize myComic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - set my comic
-(void)setMyComic:(Comic *)comic {
    myComic = comic;
    if (myComic.cover) {
        
    }
    [self.view setNeedsDisplay];
}

- (IBAction)downloadAction:(id)sender {
}
@end
