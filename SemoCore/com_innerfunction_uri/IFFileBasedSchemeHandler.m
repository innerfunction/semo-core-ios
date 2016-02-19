//
//  IFFileBasedSchemeHandler.m
//  EventPacComponents
//
//  Created by Julian Goacher on 13/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFFileBasedSchemeHandler.h"

@implementation IFFileBasedSchemeHandler

- (id)initWithDirectory:(NSSearchPathDirectory)dirs {
    self = [super init];
    if (self) {
        paths = NSSearchPathForDirectoriesInDomains( dirs, NSUserDomainMask, YES);
        fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (id)initWithPath:(NSString*)path {
    self = [super init];
    if (self) {
        paths = [NSArray arrayWithObject:path];
        fileManager = [NSFileManager defaultManager];
    }
    return self;
}

#define IsRelative(uri) (![uri.name hasPrefix:@"/"])

- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference {
    if (IsRelative(uri)) {
        uri = [uri copyOf];
        uri.name = [NSString stringWithFormat:@"%@/%@", [reference.name stringByDeletingLastPathComponent], uri.name];
    }
    return uri;
}

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params {
    IFResource* resource = nil;
    for (NSString* path in paths) {
        resource = [self dereference:uri againstPath:path];
        if (resource) {
            break;
        }
    }
    return resource;
}

- (IFResource *)dereference:(IFCompoundURI *)uri againstPath:(NSString *)path {
    NSString *filePath = [path stringByAppendingPathComponent:uri.name];
    BOOL isDir;
    BOOL exists = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (exists) {
        if (isDir) {
            return [[IFDirectoryResource alloc] initWithPath:filePath uri:uri];
        }
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        NSFileHandle* handle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:nil];
        if (handle) {
            return [[IFFileResource alloc] initWithHandle:handle url:fileURL path:filePath uri:uri];
        }
    }
    return nil;
}

@end
