//
//  IFFileResource.m
//  EPCore
//
//  Created by Julian Goacher on 02/07/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import "IFFileResource.h"
#import "IFTypeConversions.h"

@implementation IFFileDescription

- (id)initWithHandle:(NSFileHandle *)handle url:(NSURL *)url path:(NSString *)path {
    self = [super init];
    if (self) {
        self.handle = handle;
        self.url = url;
        self.path = path;
    }
    return self;
}

@end

@implementation IFFileResource

- (id)initWithData:(id)data uri:(IFCompoundURI *)uri {
    self = [super initWithData:data uri:uri];
    if (self) {
        self.fileDescription = data;
    }
    return self;
}

- (NSString *)asString {
    return [NSString stringWithContentsOfURL:self.fileDescription.url encoding:NSUTF8StringEncoding error:nil];
}

- (NSData *)asData {
    return [self.fileDescription.handle readDataToEndOfFile];
}

- (UIImage *)asImage {
    // NOTE: We first attempt to resolve the image as a named image (i.e. as an image packaged with the app) first, before
    // attempting to load it as a file from the specified path. Is there a small posibility that this could load the wrong image,
    // in certain circumstances?
    UIImage *image = [IFTypeConversions asImage:self.uri.name];
    if (!image) {
        image = [UIImage imageWithData:[self asData]];
    }
    return image;
}

- (id)asJSONData {
    return [IFTypeConversions asJSONData:[self asString]];
}

- (id)asRepresentation:(NSString *)representation {
    if ([@"string" isEqualToString:representation]) {
        return [self asString];
    }
    if ([@"data" isEqualToString:representation]) {
        return [self asData];
    }
    if ([@"image" isEqualToString:representation]) {
        return [self asImage];
    }
    if ([@"json" isEqualToString:representation]) {
        return [self asJSONData];
    }
    return [super asRepresentation:representation];
}

- (NSURL *)externalURL {
    return self.fileDescription.url;
}

@end

