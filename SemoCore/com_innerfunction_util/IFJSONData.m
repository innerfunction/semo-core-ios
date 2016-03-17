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
//  Created by Julian Goacher on 23/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFJSONData.h"

@implementation IFJSONPropertyHandler

- (id)resolveName:(NSString *)name on:(id)value representation:(NSString *)representation {
    // Resolve the named property against the current value if it conforms to key/value coding.
    if ([value respondsToSelector:@selector(objectAtIndex:)]) {
        // NOTE: Because [NSString integerValue] returns 0 for non-numeric values, the operation of
        // this code part is different from Android, which will return null for non-integer name values
        // at this point.
        NSInteger i = [name integerValue];
        value = [value objectAtIndex:i];
        value = [self modifyValue:value forName:name representation:representation];
    }
    else if ([value respondsToSelector:@selector(objectForKey:)]) {
        value = [value objectForKey:name];
        value = [self modifyValue:value forName:name representation:representation];
    }
    else {
        value = nil;
    }
    return value;
}

- (id)modifyValue:(id)value forName:(id)name representation:(NSString *)representation {
    // Return the value unchanged.
    return value;
}

@end

@implementation IFJSONData

static IFJSONPropertyHandler* DefaultHandler;

+ (void)initialize {
    if (!DefaultHandler) {
        DefaultHandler = [[IFJSONPropertyHandler alloc] init];
    }
}

+ (IFJSONPropertyHandler *)getDefaultHandler {
    return DefaultHandler;
}

// Resolve the specified path using the default JSON property handler.
+ (id)resolvePath:(NSString *)path onData:(id)data {
    return [IFJSONData resolvePath:path onData:data handler:[IFJSONData getDefaultHandler] representation:nil];
}

+ (id)resolvePath:(NSString *)path onData:(id)data handler:(IFJSONPropertyHandler *)handler representation:(NSString *)representation {
    id result = data;
    // @ref is a dotted path reference, break it into an array of path components.
    NSArray *pathComponents = [path componentsSeparatedByString:@"."];
    // Iterate over the path components.
    for (NSString *name in pathComponents) {
        if (!result) {
            break;
        }
        // Resolve the current path component.
        result = [handler resolveName:name on:result representation:representation];
    }
    return result;
}

@end
