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
    }
    return self;
}

- (id)initWithPath:(NSString*)path {
    self = [super init];
    if (self) {
        paths = [NSArray arrayWithObject:path];
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

- (IFResource *)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params parent:(IFResource *)parent {
    IFResource* resource = nil;
    for (NSString* path in paths) {
        resource = [self resolveURI:uri againstPath:path parent:parent];
        if (resource) {
            break;
        }
    }
    return resource;
}

- (IFResource *)resolveURI:(IFCompoundURI *)uri againstPath:(NSString *)path parent:(IFResource *)parent {
    NSString *filePath = [path stringByAppendingPathComponent:uri.name];
    NSLog(@"%@ -> %@", uri, filePath);
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:nil];
    if (handle) {
        IFFileDescription *fileDesc = [[IFFileDescription alloc] initWithHandle:handle url:fileURL path:filePath];
        return [[IFFileResource alloc] initWithData:fileDesc uri:uri parent:parent];
    }
    return nil;
}

@end
