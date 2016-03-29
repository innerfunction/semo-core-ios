// Copyright 2016 InnerFunction Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFNamedScheme.h"
#import "IFContainer.h"
#import "IFPendingNamed.h"

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
        if ([result isKindOfClass:[IFPendingNamed class]]) {
            ((IFPendingNamed *)result).referencePath = path;
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
