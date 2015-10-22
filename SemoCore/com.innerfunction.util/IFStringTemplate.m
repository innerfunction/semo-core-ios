//
//  EPStringTemplate.m
//  EventPacComponents
//
//  Created by Julian Goacher on 12/04/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFStringTemplate.h"
#import "IFRegExp.h"

@interface IFStringTemplate()

- (void)parse:(NSString*)s;
- (EPStringTemplateBlock)textBlock:(NSString*)text;
- (EPStringTemplateBlock)refBlock:(NSString*)ref;

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

- (EPStringTemplateBlock)textBlock:(NSString *)text {
    return ^(id ctx) {
        return text;
    };
}

- (EPStringTemplateBlock)refBlock:(NSString *)ref {
    /*
    NSArray* path = [ref componentsSeparatedByString:@"."];
    NSInteger len = [path count];
    */
    return ^(id ctx) {
        /*
        SEL valueForKey = @selector(valueForKey:);
        for (NSInteger i = 0; i < len && ctx; i++ ) {
            if ([ctx respondsToSelector:valueForKey]) {
                @try {
                    ctx = [ctx valueForKey:[path objectAtIndex:i]];
                }
                @catch (NSException *e) {
                    ctx = nil;
                }
            }
            else {
                ctx = nil;
            }
        }
        return ctx ? [ctx description] : @"";
        */
        id val = nil;
        if ([ctx respondsToSelector:@selector(valueForKeyPath:)]) {
            @try {
                val = [ctx valueForKeyPath:ref];
            }
            @catch (NSException *e) {
                val = e;
            }
        }
        return val ? [val description] : @"";
    };
}

- (NSString*)render:(id)context {
    NSMutableString* result = [[NSMutableString alloc] init];
    for (EPStringTemplateBlock block in blocks) {
        [result appendString:block( context )];
    }
    return result;
}

+ (IFStringTemplate*)templateWithString:(NSString *)s {
    return [[IFStringTemplate alloc] initWithString:s];
}

+ (NSString*)render:(NSString *)t context:(id)context {
    return [[IFStringTemplate templateWithString:t] render:context];
}

@end
