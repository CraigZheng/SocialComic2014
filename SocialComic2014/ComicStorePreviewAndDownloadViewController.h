//
//  ComicStorePreviewAndDownloadViewController.h
//  SocialComic2014
//
//  Created by Craig on 23/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comic.h"

@interface ComicStorePreviewAndDownloadViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;
@property (strong, nonatomic) Comic *myComic;
@property (strong, nonatomic) IBOutlet UIView *coverView;
@property (strong, nonatomic) IBOutlet UIImageView *comicCoverPreviewImageView;
- (IBAction)downloadAction:(id)sender;
@end
