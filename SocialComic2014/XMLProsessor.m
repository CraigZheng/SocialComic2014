//
//  XMLProsessor.m
//  SocialComic2014
//
//  Created by Craig on 7/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "XMLProsessor.h"
#import "SMXMLDocument.h"
#import "Comic.h"

@implementation XMLProsessor
-(NSArray *)parseXML:(NSData *)xmlData{
    NSMutableArray *comics = [NSMutableArray new];
    NSError *error;
    SMXMLDocument *document = [SMXMLDocument documentWithData:xmlData error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    for (SMXMLElement *element in [document.root childrenNamed:@"Comic"]) {
        Comic* newComic = [Comic new];
        newComic.zipFileURL = [element valueWithPath:@"ZipFileURL"];
        newComic.descriptionFileURL = [element valueWithPath:@"DescriptionFileURL"];
        newComic.coverFileURL = [element valueWithPath:@"CoverURL"];
        [comics addObject:newComic];
    }
    return comics;
}
@end
