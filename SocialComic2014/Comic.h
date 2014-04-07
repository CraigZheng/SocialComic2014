//
//  Comic.h
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comic : NSObject
//remove URL
@property NSString *coverFileURL;
@property NSString *zipFileURL;
@property NSString *descriptionFileURL;
//local URL
@property NSString *localCoverFile;
@property NSString *localZipFile;
@property NSString *localDescriptionFile;
@property NSString *unzipToFolder;
@end
