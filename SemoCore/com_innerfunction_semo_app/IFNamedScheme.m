//
//  IFNamedScheme.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFNamedScheme.h"
#import "IFContainer.h"

@implementation IFNamedSchemeHandler

- (id)initWithContainer:(IFContainer *)container {
    self = [super init];
    if (self) {
        _container = container;
    }
    return self;
}

- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference {
    return uri;
}

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params {
    // Break the named reference into the initial name and a trailing path.
    // e.g. 'object.sub.property' -> name = 'object' path = 'sub.property'
    NSString *name = nil, *path = nil;
    NSRange range = [uri.name rangeOfString:@"."];
    if (range.location == NSNotFound) {
        name = uri.name;
    }
    else {
        name = [uri.name substringToIndex:range.location];
        NSInteger idx = range.location + 1;
        if (idx < [uri.name length]) {
            path = [uri.name substringFromIndex:idx];
        }
    }
    // Get the named object.
    id result = [_container getNamed:name];
    // If a path is specified then evaluate that on the named object.
    if (path) {
        result = [result valueForKeyPath:path];
    }
    return result;
}

@end
