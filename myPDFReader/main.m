//
//  main.m
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-23.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        int retVal;
        @try {
            retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"exception reason ---- %@",exception.reason);
            NSLog(@"stackSymbols ---- %@",exception.callStackSymbols);

        }
        @finally {
            //
        }
        return retVal;
    }
}
