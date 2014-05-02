//
//  ComicDownloadIndicatorViewController.h
//  SocialComic2014
//
//  Created by Craig on 2/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComicDownloadIndicatorViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *downloadingNumber;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *downloadingActivityIndicator;
@property NSInteger numberToShow;
@property BOOL hidden;

-(void)startAnimating;
-(void)stopAnimating;
-(void)addNumber;
-(void)minusNumber;
-(void)hide;
-(void)show;
@end
