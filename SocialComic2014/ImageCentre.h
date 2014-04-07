//
//  ImageDownloader.h
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageCentre : NSObject

-(void)downloadImageWithURL:(NSString*)imgURL;
-(void)stopDownloadingOfURL:(NSString*)imgURL;
-(void)stopAllDownloading;
@end
