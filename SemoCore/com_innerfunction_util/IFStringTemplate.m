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
//  Created by Julian Goacher on 12/04/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFStringTemplate.h"
#import "IFRegExp.h"

/**
 * A block type used internally by the template engine to represent different nodes
 * of the compiled template.
 */
typedef NSString* (^IFStringTemplateBlock) (id context, BOOL uriEncode);

@interface IFStringTemplate()

- (void)parse:(NSString*)s;
- (IFStringTemplateBlock)textBlock:(NSString*)text;
- (IFStringTemplateBlock)refBlock:(NSString*)ref;

@end

@implementation IFStringTemplate

- (id)initWithString:(NSString *)s {
    self = [super init];
    if (self) {
        blocks = [[NSMutableArray alloc] init];
        [self parse:s];
    }
    return self;
}

- (void)parse:(NSString *)s {
    IFRegExp *regex = [[IFRegExp alloc] initWithPattern:@"^([^{]*)[{]([-a-zA-Z0-9_$.]+)[}](.*)$"];
    NSMutableArray *refs = [[NSMutableArray alloc] init];
    while (s) {
        NSArray* r = [regex match:s];
        if (r) {
            [blocks addObject:[self textBlock:[r objectAtIndex:1]]];
            NSString *ref = [r objectAtIndex:2];
            [blocks addObject:[self refBlock:ref]];
            [refs addObject:ref];
            s = [r objectAtIndex:3];
        }
        else {
            NSInteger i = [s rangeOfString:@"}"].location;
            if (i == NSNotFound) {
                [blocks addObject:[self textBlock:s]];
                s = nil;
            }
            else {
                [blocks addObject:[self textBlock:[s substringToIndex:i]]];
                s = [s substringFromIndex:i];
            }
        }
    }
    _refs = refs;
}

- (IFStringTemplateBlock)textBlock:(NSString *)text {
    return ^(id ctx, BOOL uriEncode) {
        return text;
    };
}

- (IFStringTemplateBlock)refBlock:(NSString *)ref {
    return ^(id ctx, BOOL uriEncode) {
        id val = nil;
        if ([ctx respondsToSelector:@selector(valueForKeyPath:)]) {
            @try {
                val = [[ctx valueForKeyPath:ref] description];
            }
            @catch (NSException *e) {
                val = e;
            }
            if (val && uriEncode) {
                val = [val stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            }
        }
        return val ? val : @"";
    };
}

- (NSString *)render:(id)context {
    return [self render:context uriEncode:NO];
}

- (NSString*)render:(id)context uriEncode:(BOOL)uriEncode {
    NSMutableString* result = [[NSMutableString alloc] init];
    for (IFStringTemplateBlock block in blocks) {
        [result appendString:block( context, uriEncode )];
    }
    return result;
}

+ (IFStringTemplate*)templateWithString:(NSString *)string {
    return [[IFStringTemplate alloc] initWithString:string];
}

+ (NSString*)render:(NSString *)template context:(id)context {
    return [[IFStringTemplate templateWithString:template] render:context];
}

+ (NSString*)render:(NSString *)template context:(id)context uriEncode:(BOOL)uriEncode {
    return [[IFStringTemplate templateWithString:template] render:context uriEncode:uriEncode];
}

@end
