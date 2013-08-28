//
//  BookCell.m
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-27.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import "BookCell.h"

static NSArray *observerKeys;
@implementation BookCell

@synthesize book = _book;
@synthesize progressView = _progressView;
@synthesize textLabel = label1;
@synthesize detailTextLabel = label2;
@synthesize imageView = imgview;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (nil == observerKeys) {
            
        }
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (nil == observerKeys) {
        observerKeys = @[@"progress",@"downloadRate",@"status"];
    }
    [label1 setNumberOfLines:0];
    [label2 setTextColor:[UIColor lightGrayColor]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (UILabel *)textLabel
{
    return label1;
}

- (UILabel *)detailLabel
{
    return label2;
}

- (UIImageView *)imageView
{
    return imgview;
}

- (id)initWithBook:(Book *)book reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        if (nil == observerKeys) {
            observerKeys = @[@"progress",@"downloadRate",@"status"];
        }
        self.book = book;
        [self.detailTextLabel setTextColor:[UIColor lightGrayColor]];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setBook:(Book *)book
{
    if (![_book isEqual:book]) {
        for (NSString * key in observerKeys) {
            [_book removeObserver:self forKeyPath:key];
        }
        _book = book;
        for (NSString * key in observerKeys) {
            [_book addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        }
        [self updateProgress:_book.progress];
        if (_book.status == BookStatusDownloading) {
            [self updateDownloadRate:_book.downloadRate];
        }
        [self updateBookStatus];
    }
}

#pragma mark- 

- (void)updateProgress:(CGFloat)newProgress
{
    _progressView.progress = newProgress;
}

- (void)updateDownloadRate:(CGFloat)downloadRate
{
    [self.detailTextLabel setText:[NSString stringWithFormat:@"%0.02fKb/s",downloadRate]];
}

- (void)updateBookStatus
{
    switch (_book.status) {
        case BookStatusDownloaded:
            [_progressView setHidden:YES];
            [self.detailTextLabel setText:@"已下载"];
            break;
        case BookStatusDownloading:
            [self.detailTextLabel setText:@"0.00kb/s"];
            break;
        case BookStatusDownloadPause:
            [self.detailTextLabel setText:@"暂停中"];
            break;
        case BookStatusUnDownload:
            [self.detailTextLabel setText:@"未下载"];
            [_progressView setHidden:NO];
            [self updateProgress:0.0f];
            break;
            
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *newValue = [change valueForKey:@"new"];
    if ([keyPath isEqualToString:@"progress"]) {
        [self updateProgress:[newValue floatValue]];
    }
    else if ([keyPath isEqualToString:@"downloadRate"]){
        [self updateDownloadRate:[newValue floatValue]];
    }
    else if([keyPath isEqualToString:@"status"]){
        [self updateBookStatus];
    }
}

@end
