//
//  jsonUtils.h
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-23.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface jsonUtils : NSObject

+ (NSMutableArray *)parserBooksWithStr:(NSString *)jsonStr;
+ (NSMutableArray *)parserBooksWithData:(NSData *)jsonData;

@end
