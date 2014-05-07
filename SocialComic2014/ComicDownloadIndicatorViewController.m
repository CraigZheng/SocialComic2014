//
//  ComicDownloadIndicatorViewController.m
//  SocialComic2014
//
//  Created by Craig on 2/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "ComicDownloadIndicatorViewController.h"

@interface ComicDownloadIndicatorViewController ()

@end

@implementation ComicDownloadIndicatorViewController
@synthesize downloadingActivityIndicator;
@synthesize downloadingNumber;
@synthesize numberToShow;
@synthesize hidden;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    numberToShow = 0;
    hidden = false;
    
    self.view.layer.masksToBounds = NO;
    self.view.layer.cornerRadius = 20;
    self.view.layer.shadowOffset = CGSizeMake(1, 1);
    self.view.layer.shadowRadius = 5;
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
}

-(void)startAnimating {
    [downloadingActivityIndicator startAnimating];
}

-(void)stopAnimating {
    [downloadingActivityIndicator stopAnimating];
}

-(void)addNumber {
    numberToShow ++;
    downloadingNumber.text = [NSString stringWithFormat:@"%ld", (long)numberToShow];
}

-(void)minusNumber {
    numberToShow --;
    downloadingNumber.text = [NSString stringWithFormat:@"%ld", (long)numberToShow];
    if (numberToShow == 0)
        [self hide];
}

-(void)show {
    self.view.alpha = 0.0;
    self.view.hidden = NO;
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.2];
    self.view.alpha = 1.0;
    [UIView commitAnimations];
    self.hidden = false;
}

-(void)hide {
    self.view.alpha = 1.0;
    self.view.hidden = NO;
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.2];
    self.view.alpha = 0.0;
    [UIView commitAnimations];
    self.hidden = true;
}
@end
