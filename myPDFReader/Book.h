//
//  Book.h
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-23.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BookStatus){
    BookStatusUnDownload = 0,
    BookStatusDownloading = 1,
    BookStatusDownloadPause = 2,
    BookStatusDownloaded = 3
};

typedef NS_ENUM(NSInteger, BookDownloadAction) {
    BookDownloadActionStart,
    BookDownloadActionResume,
    BookDownloadActionCancel
};

static const NSString *BookDownloadFinishedNotification = @"BookDownloadFinishedNotification";

@interface Book : NSObject<NSObject,NSCoding>

@property (nonatomic,strong) NSString *author;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *description;
@property (nonatomic,strong) NSString *imgUrl;
@property (nonatomic,strong) NSString *downloadUrl;
@property (nonatomic,readonly) NSString *localFilePath;
@property (nonatomic,readonly) NSString *tempFilePath;
@property (nonatomic,setter = setStatus:,getter=status) NSInteger status;
@property (nonatomic) CGFloat progress;
@property (nonatomic) CGFloat downloadRate;
+ (Book *)bookFromDict:(NSDictionary *)dict;
+ (Book *)bookFromArchivedFile:(NSString *)filename;
+ (NSString *)archiveFilePath:(NSString *)filename;
+ (NSString *)archiveFileDirectory;
- (BOOL)save;

@end
