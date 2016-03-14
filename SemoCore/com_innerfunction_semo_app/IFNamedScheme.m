//
//  IFNamedScheme.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFNamedScheme.h"
#import "IFContainer.h"
#import "IFIOCPendingNamed.h"

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
        // Check for pending names. These are only returned during the container's configuration cycle, and are
        // used to resolve circular dependencies. When these are returned then just the path needs to be recorded.
        if ([result isKindOfClass:[IFIOCPendingNamed class]]) {
            ((IFIOCPendingNamed *)result).referencePath = path;
        }
        else {
            @try {
                result = [result valueForKeyPath:path];
            }
            @catch (id exception) {}
        }
    }
    return result;
}

@end
