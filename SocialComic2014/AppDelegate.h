//
//  AppDelegate.h
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#define COMIC_SELECTED_NOTIFICATION @"COMIC_SELECTED_NOTIFICATION"
#define SELECTED_COMIC_KEY @"SELECTED_COMIC_KEY"
#define SELECTED_PAGE_KEY @"SELECTED_PAGE_KEY"

#import <UIKit/UIKit.h>

@class ComicPagingScrollViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property NSString *coverImageFolder;
@property NSString *descriptionFileFolder;
@property NSString *zipFileFolder;
@property NSString *unzipFolder;
@property NSMutableSet *viewControllersAwaitingRotationEvents;
@property BOOL shouldAllowMultipleInterfaceOrientation;
@property UIViewController *bookcollectionViewController;

+(AppDelegate*)sharedAppDelegate;
+(void)fadeInView:(UIView*)view;
+(void)fadeOutView:(UIView*)view;
-(void)doSingleViewHideAnimation:(UIView*)incomingView :(NSString*)animType :(CGFloat)duration;
-(void)doSingleViewShowAnimation:(UIView*)incomingView :(NSString*)animType :(CGFloat)duration;
@end
