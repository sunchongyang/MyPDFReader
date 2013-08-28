//
//  Book.m
//  myPDFReader
//
//  Created by Sun Chongyang on 13-8-23.
//  Copyright (c) 2013年 Sun Chongyang. All rights reserved.
//

#import "Book.h"

@implementation Book

@synthesize author;
@synthesize name;
@synthesize description;
@synthesize imgUrl,downloadUrl,localFilePath,tempFilePath,progress,downloadRate;
@synthesize status = _status;

+ (NSString *)documentsPath
{
	NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	return [documentsPaths objectAtIndex:0]; // Path to the application's "~/Documents" directory
}

+ (NSString *)archiveFileDirectory
{
    return [[Book documentsPath] stringByAppendingPathComponent:@"CachedObjects"];
}

+ (NSString *)archiveFilePath:(NSString *)filename
{
	assert(filename != nil);
   	NSString *archivePath = [Book archiveFileDirectory];
    NSString *archiveName = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
    BOOL isDirectory;
    if (!([[NSFileManager defaultManager] fileExistsAtPath:archivePath isDirectory:&isDirectory] && isDirectory)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:archivePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
	return [archivePath stringByAppendingPathComponent:archiveName]; // "{archivePath}/'filename'.plist"
}

+ (Book *)bookFromDict:(NSDictionary *)dict
{
    if (dict) {
        Book *book = [[Book alloc] init];
        
        book.author = [dict objectForKey:@"author"];
        book.name = [dict objectForKey:@"name"];
        book.description = [dict objectForKey:@"description"];
        book.imgUrl = [dict objectForKey:@"imgUrl"];
        book.downloadUrl = [dict objectForKey:@"downloadUrl"];
        
        Book *savedBook = [Book bookFromArchivedFile:book.name];
        if (savedBook) {
            book.progress = savedBook.progress;
        }
        
        return book;
    }
    
    return nil;
}

+ (Book *)bookFromArchivedFile:(NSString *)filename
{
	Book *book = nil; // ReaderDocument object
    
	NSString *withName = [filename lastPathComponent]; // File name only
    
	NSString *archiveFilePath = [Book archiveFilePath:withName];
    
	@try // Unarchive an archived ReaderDocument object from its property list
	{
		book = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
	}
	@catch (NSException *exception) // Exception handling (just in case O_o)
	{
#ifdef DEBUG
        NSLog(@"%s Caught %@: %@", __FUNCTION__, [exception name], [exception reason]);
#endif
	}
    
	return book;
}

- (NSString *)localFilePath
{
    return [[[self class] documentsPath] stringByAppendingPathComponent:self.name];
}

- (NSString *)tempFilePath
{
    return [[self localFilePath] stringByAppendingString:@".tmp"];
}

- (void)saveBookStatus
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:_status forKey:self.name];
}

- (BookStatus)getBookStatus
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:self.name];
}

- (void)setStatus:(BookStatus)status
{
    if (_status != status) {
        _status = status;
        [self saveBookStatus];
    }
}

- (BookStatus)status
{
    return [self getBookStatus] ? [self getBookStatus] : BookStatusUnDownload;
}

- (BOOL)save
{
    NSString *archiveFilePath = [Book archiveFilePath:name];
	return [NSKeyedArchiver archiveRootObject:self toFile:archiveFilePath];
}

#pragma mark -  NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:author forKey:@"Author"];
	[encoder encodeObject:name forKey:@"Name"];
	[encoder encodeObject:description forKey:@"Description"];
	[encoder encodeObject:[NSNumber numberWithInteger:_status] forKey:@"Status"];
	[encoder encodeObject:imgUrl forKey:@"ImgUrl"];
	[encoder encodeObject:downloadUrl forKey:@"DownloadUrl"];
    [encoder encodeObject:[NSNumber numberWithFloat:progress] forKey:@"Progress"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init])) // Superclass init
	{
		self.author = [decoder decodeObjectForKey:@"Author"];
        self.name = [decoder decodeObjectForKey:@"Name"];
        self.description = [decoder decodeObjectForKey:@"Description"];
        self.status = [[decoder decodeObjectForKey:@"Status"] integerValue];
        self.imgUrl = [decoder decodeObjectForKey:@"ImgUrl"];
        self.downloadUrl = [decoder decodeObjectForKey:@"DownloadUrl"];
        self.progress = [[decoder decodeObjectForKey:@"Progress"] floatValue];
	}
    
	return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[Book class]]) {
        if ([((Book *)object).name isEqual:name]) {
            return YES;
        }
    }
    
    return NO;
}

@end
