//
//  IFHTTPUtils.m
//  EPCore
//
//  Created by Julian Goacher on 26/10/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import "IFHTTPUtils.h"
#import "IFTypeConversions.h"

#define LogTag @"[IFHTTPUtils]"

static NSOperationQueue *requestQueue;

@implementation IFHTTPUtils

+ (void)initialize {
    requestQueue = [[NSOperationQueue alloc] init];
}

+ (IFHTTPGetFileClient *)getFileFromURL:(NSString *)url offset:(NSUInteger)offset path:(NSString *)path then:(IFGetFileCallback)callback {
    IFHTTPGetFileClient *client = [[IFHTTPGetFileClient alloc] initWithURL:url offset:offset path:path callback:callback];
    [client startInBackground:requestQueue];
    return client;
}

+ (IFHTTPGetJSONClient *)getJSONFromURL:(NSString *)url then:(IFGetJSONCallback)callback {
    IFHTTPGetJSONClient *client = [[IFHTTPGetJSONClient alloc] initWithURL:url callback:callback];
    [client startInBackground:requestQueue];
    return client;
}

@end

@implementation IFHTTPClient

- (id)init {
    self = [super init];
    if (self) {
        charset = NSUTF8StringEncoding;
    }
    return self;
}

- (NSStringEncoding)getCharset {
    return charset;
}

- (void)startInBackground:(NSOperationQueue *)queue {
    // See http://iosdevelopmentjournal.com/blog/2013/01/27/running-network-requests-in-the-background/
    // for a description of this execution method.
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    connection.delegateQueue = queue;
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    CFStringRef textenc = (__bridge CFStringRef)response.textEncodingName;
    if (textenc) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding( textenc );
        charset = CFStringConvertEncodingToNSStringEncoding( encoding );
    }
}

@end

@implementation IFHTTPGetFileClient

- (id)initWithURL:(NSString *)_url offset:(NSUInteger)offset path:(NSString *)path callback:(IFGetFileCallback)_callback {
    self = [super init];
    if (self) {
        callback = [_callback copy];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager createFileAtPath:path contents:nil attributes:nil];
        }
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        NSURL *url = [NSURL URLWithString:_url];
        NSMutableURLRequest *_request = [NSMutableURLRequest requestWithURL:url];
        if (offset > 0) {
            NSString *rangeHeaderValue = [NSString stringWithFormat:@"%ld-", (long)offset];
            [_request setValue:rangeHeaderValue forHTTPHeaderField:@"Range"];

        }
        request = _request;
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([data length] > 0) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    callback( YES );
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@ File download error %@", LogTag, error );
    callback( NO );
}

@end

@implementation IFHTTPGetJSONClient

- (id)initWithURL:(NSString *)_url callback:(IFGetJSONCallback)_callback {
    self = [super init];
    if (self) {
        callback = [_callback copy];
        NSURL *url = [NSURL URLWithString:_url];
        request = [NSURLRequest requestWithURL:url];
        json = @"";
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *s = [[NSString alloc] initWithData:data encoding:[self getCharset]];
    json = [json stringByAppendingString:s];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    id data = [IFTypeConversions asJSONData:json];
    callback( data );
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@ JSON download error %@", LogTag, error );
    callback( nil );
}

@end