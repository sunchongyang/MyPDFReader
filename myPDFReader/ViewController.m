//
//  ViewController.m
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-23.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import "ViewController.h"
#import "ReaderViewController.h"
#import "MBProgressHUD.h"
#import "jsonUtils.h"
#import "Book.h"
#import "UIImageView+WebCache.h"
#import "BookView.h"

#define SERVER_DATA_URL @"http://pm.fabgou.com/shouji/testJson"

@interface ViewController ()
{
    __strong NSMutableArray *_testDatas;
    __strong ListViewController *_listView;
    UIButton *_listButton;
    BOOL islistMode;
}

@end

@implementation ViewController

- (void)addBg
{
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    [bg setFrame:self.view.bounds];
    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    bg.alpha = 0.5;
    [self.view addSubview:bg];
}

- (void)createCarousel
{
    _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _carousel.backgroundColor = [UIColor clearColor];
    _carousel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _carousel.delegate = self;
    _carousel.dataSource = self;
    _carousel.type = iCarouselTypeCoverFlow;
    
    [self.view addSubview:_carousel];
    
    _imageTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40)];
    _imageTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    _imageTitleLabel.backgroundColor = [UIColor clearColor];
    _imageTitleLabel.textAlignment = UITextAlignmentCenter;
    _imageTitleLabel.font = [UIFont systemFontOfSize:20.0f];
    _imageTitleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_imageTitleLabel];
    
}

- (void)createListButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
    button.frame = CGRectMake(self.view.bounds.size.width - 50, 2, 40, 40);
    [button addTarget:self action:@selector(listButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [button setEnabled:NO];
    [self.view addSubview:button];
    _listButton = button;
}

- (void)listButtonClicked
{
    [self changeToView:YES];
}

- (void)loadNetData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:SERVER_DATA_URL]];
    [request setDelegate:self];
    [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
    [request startAsynchronous];
}

- (void)loadCachedDatas
{
    NSString *cachedFilePath = [Book archiveFileDirectory];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachedFilePath error:nil];
    NSMutableArray *books = [NSMutableArray arrayWithCapacity:1];
    for (NSString *file in contents) {
        NSString *filePath = [cachedFilePath stringByAppendingPathComponent:file];
        Book *book = [Book bookFromArchivedFile:filePath];
        if (book) {
            [books addObject:book];
        }
    }

    _testDatas = books;
    [_carousel reloadData];
    [_listButton setEnabled:YES];
}

- (void)showErrorMsg
{
    MBProgressHUD *mb = [MBProgressHUD HUDForView:self.view];
    mb.yOffset = 150;
    mb.mode = MBProgressHUDModeText;
    mb.labelText = @"获取数据错误";
    
    [mb hide:YES afterDelay:2];
}

#pragma mark - ASIHttpRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    _testDatas = [jsonUtils parserBooksWithData:request.responseData];
    if ([_testDatas count]) {
        [self saveDatas];
        [_carousel reloadData];
        [_listButton setEnabled:YES];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
    else{
        [self loadCachedDatas];
        if ([_testDatas count]) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        else{
            [self showErrorMsg];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self loadCachedDatas];
    if ([_testDatas count]) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
    else{
        [self showErrorMsg];
    }
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBg];
    [self createCarousel];
    [self createListButton];
    [self addObservers];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(![_testDatas count]){
        [self loadNetData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    }
    
    return YES;
}

#pragma mark -

- (void)saveDatas
{
    for (Book * book in _testDatas) {
        [book save];
    }
}

- (void)bookDidDownloaded:(NSNotification *)notification
{
    id book = notification.object;
    if ([book isKindOfClass:[Book class]]) {
        if ([[self selectedBookView].book isEqual:book] && [UIMenuController sharedMenuController].isMenuVisible) {
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        }
    }
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookDidDownloaded:) name:BookDownloadFinishedNotification object:nil];
}

#pragma mark -

- (BookView *)selectedBookView
{
    return (BookView *)_carousel.currentItemView;
}

- (void)startDownloadingAction:(id)sender
{
    if (islistMode) {
        Book *book = [_listView selectedBook];
        if (book) {
            [self excuteAction:BookDownloadActionStart forBook:book];
        }
    }
    else{
        [[self selectedBookView] startDownload];
    }
}

- (void)resumeDownloadingAction:(id)sender
{
    if (islistMode) {
        Book *book = [_listView selectedBook];
        if (book) {
            [self excuteAction:BookDownloadActionResume forBook:book];
        }
    }
    else{
        [[self selectedBookView] resumeDownload];
    }
}

- (void)cancelDownloadingAction:(id)sender
{
    if (islistMode) {
        Book *book = [_listView selectedBook];
        if (book) {
            [self excuteAction:BookDownloadActionCancel forBook:book];
        }
    }
    else{
        [[self selectedBookView] cancelDownload];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(resumeDownloadingAction:) || action == @selector(cancelDownloadingAction:) || action == @selector(startDownloadingAction:)) {
        return YES;
    }
    
    return NO;
}

- (void)showMenuForBook:(Book *)book
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
    [menu setTargetRect:CGRectMake(self.view.center.x - 5, self.view.center.y - 110, 10, 10) inView:self.view];
    [menu update];
    [menu setMenuVisible:YES animated:YES];
}

- (void)showReaderWithBook:(Book *)book
{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
	NSString *filePath = [book localFilePath]; assert(filePath != nil); // Path to last PDF file
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
	if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
	{
		ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
		readerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
		[self presentViewController:readerViewController animated:YES completion:NULL];
    }
}

- (void)changeToView:(BOOL)toList
{
    if (!_listView) {
        _listView = [[ListViewController alloc] initWithNibName:nil bundle:nil];
        _listView.datas = _testDatas;
        _listView.delegate = self;
        _listView.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _listView.view.frame = self.view.bounds;
    }
    UIViewAnimationOptions animationOption = UIViewAnimationOptionTransitionFlipFromRight;
    if (!toList) {
        animationOption = UIViewAnimationOptionTransitionFlipFromLeft;
    }
    [UIView transitionWithView:self.view duration:1.0 options:animationOption animations:^(){
        if (toList) {
            _listView.view.frame = self.view.bounds;
            [self.view addSubview:_listView.view];
        }
        else{
            [_listView.view removeFromSuperview];
        }
    } completion:^(BOOL finished){
        islistMode = toList;
    }];
}

#pragma mark -

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_testDatas count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    Book *book= [_testDatas objectAtIndex:index];
    if (view ==  nil) {
        BookView *bookView = [[BookView alloc] initWithFrame:CGRectMake(0, 0, 150, 200)];
        [bookView.imageView setImageWithURL:[NSURL URLWithString:book.imgUrl] placeholderImage:nil];
        bookView.book = book;
        view = bookView;
    }
    else{
        /*
        UIImageView *imageView = [[view subviews] lastObject];
        [imageView setImageWithURL:[NSURL URLWithString:book.imgUrl] placeholderImage:nil];
         */
    }
    
    [(ReflectionView *)view update];
    
    return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	return 0;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    NSInteger booksCount = [_testDatas count];
    return booksCount ? booksCount : 30 ;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return 200;
}

- (CATransform3D)carousel:(iCarousel *)carousel transformForItemView:(UIView *)view withOffset:(CGFloat)offset
{
    view.alpha = 1.0 - fminf(fmaxf(offset, 0.0), 1.0);
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = carousel.perspective;
    transform = CATransform3DRotate(transform, M_PI / 8.0, 0, 1.0, 0);
    return CATransform3DTranslate(transform, 0.0, 0.0, offset * carousel.itemWidth);
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return NO;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    Book *book = [_testDatas objectAtIndex:index];
    if (book.status != BookStatusDownloaded) {
        [self showMenuForBook:book];
    }
    else{
        [self showReaderWithBook:book];
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    NSInteger index = [_carousel currentItemIndex];
    if(index >= 0){
        Book *book = [_testDatas objectAtIndex:index];
        [_imageTitleLabel setText:book.name];
    }
}

#pragma mark -ListViewDelegate
- (void)openBook:(Book *)book
{
    [self showReaderWithBook:book];
}

- (void)excuteAction:(BookDownloadAction)action forBook:(Book *)book
{
    NSInteger index = [_testDatas indexOfObject:book];
    if (index != NSNotFound) {
        SEL selector = NULL;
        switch (action) {
            case BookDownloadActionStart:
                selector = @selector(startDownload);
                break;
            case BookDownloadActionResume:
                selector = @selector(resumeDownload);
                break;
            case BookDownloadActionCancel:
                selector = @selector(cancelDownload);
                break;
            default:
                break;
        }
        if (selector) {
            BookView *bookView = (BookView *)[_carousel itemViewAtIndex:index];
            [bookView performSelector:selector];
        }
    }
}

- (void)changeView
{
    [self changeToView:NO];
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{        
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
