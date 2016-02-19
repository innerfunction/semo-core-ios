//
//  EPTypeConversions.m
//  EventPacComponents
//
//  Created by Julian Goacher on 06/02/2014.
//  Copyright (c) 2014 InnerFunction. All rights reserved.
//

#import "IFTypeConversions.h"
#import "IFRegExp.h"
#import "ISO8601DateFormatter.h"
#import "IFLogging.h"
#import "objc/runtime.h"

#define Retina4DisplayHeight    568
#define IsIPhone                ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IsRetina4               ([[UIScreen mainScreen] bounds].size.height == Retina4DisplayHeight)
#define IsString(v)             ([v isKindOfClass:[NSString class]])
#define IsNumber(v)             ([v isKindOfClass:[NSNumber class]])

@implementation IFTypeConversions

+ (NSString *)asString:(id)value {
    NSString *result;
    if (IsString(value)) {
        result = value;
    }
    else if (IsNumber(value)) {
        result = [(NSNumber *)value stringValue];
    }
    else if ([value isMemberOfClass:[NSData class]]) {
        result = [[NSString alloc] initWithData:(NSData *)value
                                       encoding:NSUTF8StringEncoding];
    }
    else {
        result = [value description];
    }
    return result;
}

+ (NSNumber *)asNumber:(id)value {
    NSNumber *result = nil;
    if (IsNumber(value)) {
        result = value;
    }
    // TODO: Try parsing string value as number?
    return result;
}

+ (BOOL)asBoolean:(id)value {
    BOOL result = NO;
    NSNumber *nvalue = [IFTypeConversions asNumber:value];
    if( nvalue ) {
        result = [nvalue boolValue];
    }
    // TODO: Should yes/no true/false string values be supported?
    return result;
}

// Key for the date formatter associated object for the current thread.
static void *IFTypeConversions_threadDateFormatter;

+ (NSDate *)asDate:(id)value {
    NSDate *result = nil;
    if ([value isKindOfClass:[NSDate class]]) {
        result = value;
    }
    else if (IsNumber(value)) {
        result = [[NSDate alloc] initWithTimeIntervalSince1970:(NSTimeInterval)[(NSNumber *)value doubleValue]];
    }
    else {
        // A date formatter instance is stored as an associated object of the current thread to allow
        // efficient and thread-safe reuse of formatter objects.
        // (This is basically equivalent to a ThreadLocal in Java).
        NSThread *thread = [NSThread currentThread];
        // Attempt to read a formatter for the current thread.
        ISO8601DateFormatter *dateFormatter = objc_getAssociatedObject(thread, &IFTypeConversions_threadDateFormatter);
        if (!dateFormatter) {
            // No formatter found, so create a new one.
            dateFormatter = [[ISO8601DateFormatter alloc] init];
            objc_setAssociatedObject(thread, &IFTypeConversions_threadDateFormatter, dateFormatter, OBJC_ASSOCIATION_RETAIN);
        }
        // Parse the string representation of the current value.
        NSString *svalue = [IFTypeConversions asString:value];
        // TODO: Is error handling - try/catch - required here?
        result = [dateFormatter dateFromString:svalue];
    }
    return result;
}

/*
+ (id)asJSONData:(id)value {
}
*/

+ (NSURL *)asURL:(id)value {
    return [NSURL URLWithString:[IFTypeConversions asString:value]];
}

+ (NSData *)asData:(id)value {
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
    NSString *svalue = [IFTypeConversions asString:value];
    return [svalue dataUsingEncoding:NSUTF8StringEncoding];
}

+ (UIImage *)asImage:(id)value {
    UIImage *result = nil;
    NSString *baseName = [IFTypeConversions asString:value];
    if (baseName) {
        if (IsRetina4) {
            NSString *name = [NSString stringWithFormat:@"%@-r4", [baseName stringByDeletingPathExtension]];
            result = [UIImage imageNamed:name];
        }
        if (!result) {
            result = [UIImage imageNamed:baseName];
        }
    }
    return result;
}

+ (id)asJSONData:(id)value {
    id jsonData;
    if ([value isKindOfClass:[NSString class]]) {
        if ([IFRegExp pattern:@"^\\s*([{\\[\"\\d]|true|false)" matches:value]) {
            NSError *error = nil;
            NSData *data = [IFTypeConversions asData:value];
            jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                DDLogCError(@"[IFTypeConversions asJSONData] Parsing JSON %@\n%@", value, error);
                jsonData = value;
            }
        }
        else {
            jsonData = value;
        }
    }
    else {
        jsonData = value;
    }
    return jsonData;
}

+ (id)value:(id)value asRepresentation:(NSString *)name {
    if ([@"string" isEqualToString:name]) {
        return [IFTypeConversions asString:value];
    }
    if ([@"number" isEqualToString:name] || [@"boolean" isEqualToString:name]) {
        return [IFTypeConversions asNumber:value];
    }
    if ([@"date" isEqualToString:name]) {
        return [IFTypeConversions asDate:value];
    }
    if ([@"url" isEqualToString:name]) {
        return [IFTypeConversions asURL:value];
    }
    if ([@"data" isEqualToString:name]) {
        return [IFTypeConversions asData:value];
    }
    if ([@"image" isEqualToString:name]) {
        return [IFTypeConversions asImage:value];
    }
    if ([@"json" isEqualToString:name]) {
        return [IFTypeConversions asJSONData:value];
    }
    if ([@"default" isEqualToString:name]) {
        return value;
    }
    // Representation name not recognized, so return nil.
    return nil;
}

@end
