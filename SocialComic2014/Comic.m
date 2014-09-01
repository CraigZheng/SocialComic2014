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
    if (self.localZipFile || self.zipFileURL)
    {
        NSString *fileURL = self.localZipFile ? self.localZipFile : self.zipFileURL;
        return [[[fileURL.lastPathComponent componentsSeparatedByString:@"_"] lastObject] stringByDeletingPathExtension];
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
        if (image)
            return image;
    }
    if (self.unzipToFolder) {
        NSString *imageFile = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.unzipToFolder error:nil] firstObject];
        imageFile = [self.unzipToFolder stringByAppendingPathComponent:imageFile];
        return [UIImage imageWithContentsOfFile:imageFile];
    }
    return nil;
}

-(BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        Comic *comic = (Comic*)object;
        if ([comic.zipFileURL isEqualToString:self.zipFileURL] || [comic.localZipFile isEqualToString:self.localZipFile])
            return YES;
        return NO;
    }
    return NO;
}

-(NSUInteger)hash {
    if (self.zipFileURL) {
        return self.zipFileURL.hash;
    }
    else if (self.localZipFile)
        return self.localZipFile.hash;
    return [super hash];
}
@end
