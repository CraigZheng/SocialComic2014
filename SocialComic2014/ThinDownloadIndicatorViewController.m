//
//  ThinDownloadIndicatorViewController.m
//  SocialComic2014
//
//  Created by Craig on 27/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ThinDownloadIndicatorViewController.h"

@interface ThinDownloadIndicatorViewController ()
@property UIColor *color1;
@property UIColor *color2;
@property NSInteger progress;
@property NSTimer *updateTimer;
@end

@implementation ThinDownloadIndicatorViewController
@synthesize circularProgressView;
@synthesize backgroundView;
@synthesize color1;
@synthesize color2;
@synthesize progress;
@synthesize updateTimer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    color1 = [UIColor blueColor];
    color2 = [UIColor clearColor];
    backgroundView.layer.masksToBounds = NO;
    backgroundView.layer.cornerRadius = 5;
    backgroundView.layer.shadowOffset = CGSizeMake(1, 1);
    backgroundView.layer.shadowRadius = 5;
    backgroundView.layer.shadowOpacity = 0.5;
    backgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    
    circularProgressView.trackTintColor = color2;
    circularProgressView.progressTintColor = color1;
    circularProgressView.thicknessRatio = 0.05f;
    progress = 0;
}

-(void)show {
    self.view.hidden = NO;
}

-(void)hide {
    self.view.hidden = YES;
}

-(void)beginAnimation {
    [self updateProgressView];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
    
}

-(void)stopAnimation {
    if (updateTimer.isValid)
        [updateTimer invalidate];
}

-(void)updateProgressView {
    [circularProgressView setProgress:0 animated:NO];
    [circularProgressView setProgress:100 animated:YES];
//    progress += 5;
//    if (progress >= 100) {
//        progress = 0;
//        //reverse front and back color of the circular view
//        if (circularProgressView.trackTintColor == color2)
//            circularProgressView.trackTintColor = color1;
//        else
//            circularProgressView.trackTintColor = color2;
//        if (circularProgressView.progressTintColor == color1)
//            circularProgressView.progressTintColor = color2;
//        else
//            circularProgressView.progressTintColor = color1;
//    }
//        
//    circularProgressView.progress = progress;

}
@end
