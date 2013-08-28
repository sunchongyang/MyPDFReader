//
//  BookCell.h
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-27.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface BookCell : UITableViewCell
{
    
}

@property (nonatomic,strong) Book *book;
@property (nonatomic,strong) IBOutlet UILabel *textLabel;
@property (nonatomic,strong) IBOutlet UILabel *detailTextLabel;
@property (nonatomic,strong) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) IBOutlet UIProgressView *progressView;

- (id)initWithBook:(Book *)book reuseIdentifier:(NSString *)reuseIdentifier;

@end
