//
//  czzTouchSharingScrollView.m
//  SocialComic2014
//
//  Created by Craig on 23/06/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "czzTouchSharingScrollView.h"

@implementation czzTouchSharingScrollView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (delegate)
    {
        [delegate czzTouchBegan:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (delegate)
    {
        [delegate czzTouchMoved:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (delegate) {
        [delegate czzTouchEnded:touches withEvent:event];
    }
}

@end
