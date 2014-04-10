//
//  Comic.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "Comic.h"

@implementation Comic

-(NSString *)name{
    if (self.zipFileURL)
    {
        return [[[self.zipFileURL.lastPathComponent componentsSeparatedByString:@"_"] lastObject] stringByDeletingPathExtension];
    }
    return @"Name Not Available";
}

-(NSString *)description{
    if (self.localDescriptionFile) {
        NSString *description = [NSString stringWithContentsOfFile:self.localDescriptionFile encoding:NSUTF8StringEncoding error:nil];
        return description;
    }
    return @"Description Not Available";
}

-(UIImage*)cover {
    if (self.localCoverFile) {
        UIImage *image = [UIImage imageWithContentsOfFile:self.localCoverFile];
        return image;
    }
    return nil;
}
@end
