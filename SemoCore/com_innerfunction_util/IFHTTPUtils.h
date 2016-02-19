//
//  IFHTTPUtils.h
//  EPCore
//
//  Created by Julian Goacher on 26/10/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IFGetJSONCallback) (id);

typedef void (^IFGetFileCallback) (BOOL);

@interface IFHTTPClient : NSObject <NSURLConnectionDataDelegate> {
    NSURLRequest *request;
    NSStringEncoding charset;
}

- (NSStringEncoding)getCharset;
- (void)startInBackground:(NSOperationQueue *)queue;

@end

@interface IFHTTPGetJSONClient : IFHTTPClient {
    IFGetJSONCallback callback;
    NSString *json;
}

- (id)initWithURL:(NSString *)url callback:(IFGetJSONCallback)callback;

@end

@interface IFHTTPGetFileClient : IFHTTPClient {
    IFGetFileCallback callback;
    NSFileHandle *fileHandle;
}

- (id)initWithURL:(NSString *)url offset:(NSUInteger)offset path:(NSString *)path callback:(IFGetFileCallback)callback;

@end

// Utility methods for submitting HTTP requests. All requests are executed on the same operation queue.
@interface IFHTTPUtils : NSObject

// Get JSON data from the specified URL.
+ (IFHTTPGetJSONClient *)getJSONFromURL:(NSString *)url then:(IFGetJSONCallback)callback;

// Get a file from the specified URL and write it to the specified path. If offset is specified then only
// download data from the offset.
+ (IFHTTPGetFileClient *)getFileFromURL:(NSString *)url offset:(NSUInteger)offset path:(NSString *)path then:(IFGetFileCallback)callback;

@end
