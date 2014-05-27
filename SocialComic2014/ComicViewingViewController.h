//
//  ComicViewingViewController.h
//  SocialComic2014
//
//  Created by Craig on 7/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comic.h"

@interface ComicViewingViewController : UIViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (strong, nonatomic) IBOutlet UIToolbar *topToolbar;
//@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
//@property (strong, nonatomic) IBOutlet UIBarButtonItem *topToolbarQuitButton;
//- (IBAction)topToolbarQuitAction:(id)sender;
//@property (strong, nonatomic) IBOutlet UIBarButtonItem *topToolbarTitleButton;
@property Comic *myComic;
@property NSString *comicFile;
@end
