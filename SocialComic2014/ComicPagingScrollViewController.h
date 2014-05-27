//
//  ComicPagingScrollViewController.h
//  SocialComic2014
//
//  Created by Craig on 27/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comic.h"
#import "AppDelegate.h"

@interface ComicPagingScrollViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property Comic *myComic;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pageNumberButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleButton;
@property (strong, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;


- (IBAction)quitAction:(id)sender;
- (IBAction)previousAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)tapOnViewAction:(id)sender;


@end
