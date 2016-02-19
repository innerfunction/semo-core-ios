//
//  NSArray+IF.m
//  EPCore
//
//  Created by Julian Goacher on 25/06/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import "NSArray+IF.h"

@implementation NSArray (IF)

+ (NSArray *)arrayWithDictionaryKeys:(NSDictionary *)dictionary {
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    if ([dictionary respondsToSelector:@selector(keyEnumerator)]) {
        for (id key in [dictionary keyEnumerator]) {
            [keys addObject:key];
        }
    }
    return keys;
}

+ (NSArray *)arrayWithDictionaryValues:(NSDictionary *)dictionary forKeys:(NSArray *)keys {
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[keys count]];
    for (id key in keys) {
        [values addObject:[dictionary valueForKey:key]];
    }
    return values;
}

+ (NSArray *)arrayWithItem:(id)item repeated:(NSInteger)repeats {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:repeats];
    for (NSInteger i = 0; i < repeats; i++) {
        [result addObject:item];
    }
    return result;
}

- (NSString *)joinWithSeparator:(NSString *)separator {
    NSMutableString *result = [[NSMutableString alloc] init];
    for (id item in self) {
        if ([result length]) {
            [result appendString:separator];
        }
        [result appendString:[item description]];
    }
    return result;
}

- (NSArray *)arrayWithoutItem:(id)item {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![item isEqual:evaluatedObject];
    }];
    return [self filteredArrayUsingPredicate:filter];
}

@end
