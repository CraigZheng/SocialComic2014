//
//  Unzipper.h
//  SocialComic2014
//
//  Created by Craig on 8/05/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comic.h"

@interface Unzipper : NSObject
-(Comic*)unzipComic:(Comic*)comic :(NSString*)toPath;
@end
