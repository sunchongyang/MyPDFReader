//
//  jsonUtils.m
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-23.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import "jsonUtils.h"
#import "Book.h"
#import "SBJson.h"
@implementation jsonUtils

+ (NSMutableArray *)parserBooksWithStr:(NSString *)jsonStr
{
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return [jsonUtils parserBooksWithData:jsonData];
}

+ (NSMutableArray *)parserBooksWithData:(NSData *)jsonData
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithData:jsonData];
    NSArray *books = [dict objectForKey:@"Books"];
    if(![books isKindOfClass:[NSArray class]]){
        return nil;
    }
    NSMutableArray *booksList = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *bookDict in books) {
        Book *book = [Book bookFromDict:bookDict];
        [booksList addObject:book];
    }
    
    return booksList;
}

@end
