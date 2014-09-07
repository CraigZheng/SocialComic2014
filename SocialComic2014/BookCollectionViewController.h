//
//  BookCollectionViewController.h
//  SocialComic2014
//
//  Created by Craig on 10/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comic.h"
@interface BookCollectionViewController : UICollectionViewController

-(void)openBookmarkComic:(Comic*)comic toPage:(NSInteger)page;
@end
