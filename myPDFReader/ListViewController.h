//
//  ListViewController.h
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-27.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@protocol ListViewDelegate <NSObject>

- (void)openBook:(Book *)book;
- (void)excuteAction:(BookDownloadAction)action forBook:(Book *)book;
- (void)changeView;
@end

@interface ListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,weak) id<ListViewDelegate> delegate;

-(Book *)selectedBook;

@end
