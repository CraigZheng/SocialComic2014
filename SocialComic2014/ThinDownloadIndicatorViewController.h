//
//  ThinDownloadIndicatorViewController.h
//  SocialComic2014
//
//  Created by Craig on 27/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"

@interface ThinDownloadIndicatorViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet DACircularProgressView *circularProgressView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property BOOL shouldSpin;

-(void)beginAnimation;
-(void)stopAnimation;
-(void)show;
-(void)hide;
@end
