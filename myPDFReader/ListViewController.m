//
//  ListViewController.m
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-27.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import "ListViewController.h"
#import "BookCell.h"
#import "UIImageView+WebCache.h"

@interface ListViewController ()
{
    __strong UIToolbar *_toolBar;
    __strong UITableView *_tableView;
    NSIndexPath *_selectedIndexPath;
}

@end

@implementation ListViewController

@synthesize datas = _datas;
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSubViews];
    [self addObservers];
}

- (void)createSubViews
{
    //toolbar
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    _toolBar.barStyle = UIBarStyleDefault;
    _toolBar.tintColor = [UIColor lightGrayColor];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIButton *gridButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gridButton setFrame:CGRectMake(0, 0, 40, 40)];
    [gridButton setImage:[UIImage imageNamed:@"grid"] forState:UIControlStateNormal];
    [gridButton addTarget:self action:@selector(gridButtonClicked) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *grid = [[UIBarButtonItem alloc] initWithCustomView:gridButton];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    [_toolBar setItems:[NSArray arrayWithObjects:space,grid,nil]];
    [self.view addSubview:_toolBar];
    
    //tableview
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_tableView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setDatas:(NSMutableArray *)datas
{
    if (![_datas isEqualToArray:datas]) {
        _datas = datas;
        
        for (Book *book in _datas) {
            [book addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        }
    }
}

-(Book *)selectedBook
{
    if (_selectedIndexPath) {
        return [_datas objectAtIndex:_selectedIndexPath.row];
    }
    
    return nil;
}

#pragma mark - 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"progress"]) {
        CGFloat newProgress = [[change valueForKey:@"new"] floatValue];
    }
}

#pragma mark - private

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillHide) name:UIMenuControllerWillHideMenuNotification object:nil];
}

- (void)menuWillHide
{
    [_tableView deselectRowAtIndexPath:_selectedIndexPath animated:YES];
}

- (void)gridButtonClicked
{
    if ([_delegate respondsToSelector:@selector(changeView)]) {
        [_delegate changeView];
    }
}

- (void)excuteAction:(BookDownloadAction)action forBookAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(excuteAction:forBook:)] && indexPath) {
        [_delegate excuteAction:action forBook:[_datas objectAtIndex:indexPath.row]];
    }
}
/*
- (void)startDownloadingAction:(id)sender
{
    [self excuteAction:BookDownloadActionStart forBookAtIndexPath:_selectedIndexPath];
}

- (void)resumeDownloadingAction:(id)sender
{
    [self excuteAction:BookDownloadActionResume forBookAtIndexPath:_selectedIndexPath];
}

- (void)cancelDownloadingAction:(id)sender
{
   [self excuteAction:BookDownloadActionCancel forBookAtIndexPath:_selectedIndexPath];
}
*/

- (void)showMenuForBook:(Book *)book atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *menuItems = nil;
    if (book.status == BookStatusDownloading) {
        UIMenuItem *resume = [[UIMenuItem alloc] initWithTitle:@"暂停下载" action:@selector(resumeDownloadingAction:)];
        UIMenuItem *cancel = [[UIMenuItem alloc] initWithTitle:@"取消下载" action:@selector(cancelDownloadingAction:)];
        menuItems = [NSArray arrayWithObjects:resume,cancel, nil];
    }
    else if (book.status == BookStatusDownloadPause){
        UIMenuItem *start = [[UIMenuItem alloc] initWithTitle:@"开始下载" action:@selector(startDownloadingAction:)];
        UIMenuItem *cancel = [[UIMenuItem alloc] initWithTitle:@"取消下载" action:@selector(cancelDownloadingAction:)];
        menuItems = [NSArray arrayWithObjects:start,cancel, nil];
    }
    else if (book.status == BookStatusUnDownload){
        UIMenuItem *start = [[UIMenuItem alloc] initWithTitle:@"开始下载" action:@selector(startDownloadingAction:)];
        menuItems = [NSArray arrayWithObjects:start, nil];
    }
    
    if (menuItems == nil) {
        return;
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = menuItems;
    CGRect rect = CGRectInset([_tableView rectForRowAtIndexPath:indexPath], 20, 10);
    [menu setTargetRect:rect inView:_tableView];
    menu.arrowDirection = UIMenuControllerArrowDefault;
    [menu update];
    [menu setMenuVisible:YES animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Book *book = [_datas objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = (BookCell *)[[[NSBundle mainBundle] loadNibNamed:@"BookCell" owner:self options:nil] lastObject];
    }
    cell.book = book;
    [cell.textLabel setText:book.name];
    [cell.imageView setImageWithURL:[NSURL URLWithString:book.imgUrl] placeholderImage:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    Book *book = [_datas objectAtIndex:indexPath.row];
    if (book.status == BookStatusDownloaded) {
        if ([_delegate respondsToSelector:@selector(openBook:)]) {
            [_delegate openBook:book];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else{
        [self showMenuForBook:book atIndexPath:indexPath];
    }
}

@end
