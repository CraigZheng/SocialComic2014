//
//  AppDelegate.h
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property NSString *coverImageFolder;
@property NSString *descriptionFileFolder;
@property NSString *zipFileFolder;
@property NSString *unzipFolder;

+(AppDelegate*)sharedAppDelegate;
+(void)fadeInView:(UIView*)view;
+(void)fadeOutView:(UIView*)view;
-(void)doSingleViewHideAnimation:(UIView*)incomingView :(NSString*)animType :(CGFloat)duration;
-(void)doSingleViewShowAnimation:(UIView*)incomingView :(NSString*)animType :(CGFloat)duration;
@end
