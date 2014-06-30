//
//  czzTouchSharingScrollView.h
//  SocialComic2014
//
//  Created by Craig on 23/06/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol czzTouchSharingScrollView <NSObject>
-(void)czzTouchBegan:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)czzTouchMoved:(NSSet*)touches withEvent:(UIEvent*)event;
-(void)czzTouchEnded:(NSSet*)touches withEvent:(UIEvent*)event;
@end

@interface czzTouchSharingScrollView : UIScrollView
@property id<czzTouchSharingScrollView> delegate;
@end
