//
//  DownloadManagerTableViewController.h
//  SocialComic2014
//
//  Created by Craig on 11/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComicDownloadIndicatorViewController.h"

@interface DownloadManagerTableViewController : UITableViewController
@property ComicDownloadIndicatorViewController *downloadIndicator;

-(void)refreshComics;
@end
