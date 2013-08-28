//
//  BookView.h
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-26.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import "ReflectionView.h"
#import "ASIHTTPRequest.h"
#import "Book.h"
@interface BookView : ReflectionView<ASIHTTPRequestDelegate,ASIProgressDelegate>

{
    UIImageView *_imageView;
    __strong UILabel *_msgLabel;
    __strong UIProgressView *_progressView;
    Book *_book;
    __strong ASIHTTPRequest *_request;
}

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) Book *book;

- (void)setMessage:(NSString *)message;
- (void)startDownload;
- (void)resumeDownload;
- (void)cancelDownload;
@end
