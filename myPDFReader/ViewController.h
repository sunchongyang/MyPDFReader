//
//  ViewController.h
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-23.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "ASIHTTPRequest.h"
#import "ListViewController.h"
@interface ViewController : UIViewController<iCarouselDataSource,iCarouselDelegate,ASIHTTPRequestDelegate,ListViewDelegate>
{
    iCarousel *_carousel;
    UILabel *_imageTitleLabel;
}

- (void)saveDatas;

@end
