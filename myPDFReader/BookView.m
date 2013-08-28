//
//  BookView.m
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-26.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import "BookView.h"
#import <QuartzCore/QuartzCore.h>

@interface BookView ()
{
    NSDate *lastBytesReceived;
}

@end

@implementation BookView

@synthesize imageView = _imageView;
@synthesize book = _book;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        self.backgroundColor = [UIColor darkGrayColor];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)initSubviews
{
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:_imageView];
       
    //msgLabel
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 30, self.bounds.size.width, 20)];
    _msgLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    _msgLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _msgLabel.textAlignment = UITextAlignmentCenter;
    _msgLabel.font = [UIFont systemFontOfSize:14.0f];
    _msgLabel.textColor = [UIColor whiteColor];
    [self addSubview:_msgLabel];
    
    //progressView
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [_progressView setFrame:CGRectMake(0, self.bounds.size.height - 10, self.bounds.size.width, 10)];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_progressView];
}

- (void)addTipView
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 50, 7, 70, 20)];
    label.backgroundColor = [UIColor orangeColor];
    label.textColor = [UIColor darkTextColor];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.text = @"已下载";
    label.textAlignment = UITextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:label];
    
    label.layer.transform = CATransform3DMakeRotation(M_PI / 4.0f, 0.0f, 0.0f, 1.0f);
    
    [self update];
}

- (void)resetViewStatus
{
    BOOL shouldHidden = NO;
    if ([_book status] == BookStatusDownloaded) {
        shouldHidden = YES;
        [self addTipView];
    }
    
    [_msgLabel setHidden:shouldHidden];
    [_progressView setHidden:shouldHidden];
}

- (void)setMessage:(NSString *)message;
{
    [_msgLabel setText:message];
}

- (void)setBook:(Book *)book
{
    if (![_book isEqual:book]) {
        _book = book;
        [self resetViewStatus];
    }
}

- (void)startDownload
{
    if (!_request) {
        NSURL *requestUrl = [NSURL URLWithString:[_book.downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        _request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
        [_request setTemporaryFileDownloadPath:_book.tempFilePath];
        [_request setDownloadDestinationPath:[_book localFilePath]];
        [_request setTimeOutSeconds:30];
        [_request setAllowResumeForFileDownloads:YES];
        [_request setDownloadProgressDelegate:self];
        [_request setShouldContinueWhenAppEntersBackground:YES];
        [_request setDelegate:self];
    }
    _book.status = BookStatusDownloading;
    [self setMessage:@"0.00kb/s"];
    [_request startAsynchronous];
}

- (void)resumeDownload
{
    [_request clearDelegatesAndCancel];
    _request = nil;
    _book.status = BookStatusDownloadPause;
    [self setMessage:@"暂停中"];
}

- (void)cancelDownload
{
    [_request clearDelegatesAndCancel];
    [_request removeTemporaryDownloadFile];
    _request = nil;
    _book.status = BookStatusUnDownload;
    _progressView.progress = 0.0f;
    [self setMessage:nil];
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.error == nil) {
        _book.status = BookStatusDownloaded;
        [self setMessage:@"下载完成"];
        [self resetViewStatus];
        [[NSNotificationCenter defaultCenter] postNotificationName:BookDownloadFinishedNotification object:_book];
    }
    
    _request = nil;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    _request = nil;
    [self setMessage:@"下载出错"];
    _book.status = BookStatusDownloadPause;
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
#ifdef DEBUG
    NSLog(@"%@",responseHeaders);
#endif
}

#pragma mark - ASIProgressDelegate
- (void)setProgress:(float)newProgress
{
    [_progressView setProgress:newProgress];
    _book.progress = newProgress;
}

-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    if (!lastBytesReceived)
        lastBytesReceived = [NSDate date];
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastBytesReceived];
    
    float KB = (bytes / 1024);
    float kbPerSec =  KB * (1.0/interval); //KB * (1 second / interval (less than one second))
    _book.downloadRate = kbPerSec;
    [self setMessage:[NSString stringWithFormat:@"%0.02fKb/s",kbPerSec]];
    
    lastBytesReceived = [NSDate date];
}

@end
