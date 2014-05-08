//
//  AppDelegate.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize coverImageFolder;
@synthesize zipFileFolder;
@synthesize descriptionFileFolder;
@synthesize unzipFolder;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self checkFolders];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)checkFolders {
    NSString *libraryFolder = [NSSearchPathForDirectoriesInDomains(
                                                         NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    coverImageFolder = [libraryFolder stringByAppendingPathComponent:@"ComicCovers"];
    zipFileFolder = [libraryFolder stringByAppendingPathComponent:@"ZipFiles"];
    descriptionFileFolder = [libraryFolder stringByAppendingPathComponent:@"DescriptionFiles"];
    unzipFolder = [libraryFolder stringByAppendingPathComponent:@"UnzipComics"];
    [self checkOrCreateFolder:coverImageFolder];
    [self checkOrCreateFolder:zipFileFolder];
    [self checkOrCreateFolder:descriptionFileFolder];
    [self checkOrCreateFolder:unzipFolder];
}

-(BOOL)checkOrCreateFolder:(NSString*)folder {
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (error) {
        return NO;
    }
    return YES;
}

+(AppDelegate *)sharedAppDelegate{
    return [[UIApplication sharedApplication] delegate];
}

#pragma mark - view animations
+(void)fadeInView:(UIView*)view {
    view.alpha = 0;
    [[[AppDelegate sharedAppDelegate] window] addSubview:view];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    view.alpha = 1.0f;
    [UIView commitAnimations];

}

+(void)fadeOutView:(UIView *)view {
    view.alpha = 1.0f;
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.alpha = 0;
                     }
                     completion:^(BOOL success){
                         if (view.superview)
                             [view removeFromSuperview];
                     }];
}

+(void)doSingleViewHideAnimation:(UIView*)incomingView :(NSString*)animType :(CGFloat)duration
{
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:animType];
    
    [animation setDuration:duration];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[incomingView layer] addAnimation:animation forKey:kCATransition];
    incomingView.hidden = YES;
}

+(void)doSingleViewShowAnimation:(UIView*)incomingView :(NSString*)animType :(CGFloat)duration
{
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:animType];
    
    [animation setDuration:duration];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[incomingView layer] addAnimation:animation forKey:kCATransition];
    incomingView.hidden = NO;
}
@end
