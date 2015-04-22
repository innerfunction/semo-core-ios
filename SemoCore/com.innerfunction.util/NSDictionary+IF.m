//
//  NSDictionary+IF.m
//  EPCore
//
//  Created by Julian Goacher on 21/06/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import "NSDictionary+IF.h"

@interface IFExtendedDictionary : NSMutableDictionary {
    NSDictionary *parentDictionary;
    NSMutableDictionary *selfDictionary;
}

- (id)initWithParentDictionary:(NSDictionary *)parent;

@end

@implementation NSDictionary (IF)

- (NSDictionary *)extendWith:(NSDictionary *)values {
    IFExtendedDictionary *result = [[IFExtendedDictionary alloc] initWithParentDictionary:self];
    for (id key in [values keyEnumerator]) {
        [result setObject:[values objectForKey:key] forKey:key];
    }
    return result;
}

- (NSDictionary *)dictionaryWithAddedObject:(id)object forKey:(id)key {
    if ([self isKindOfClass:[IFExtendedDictionary class]]) {
        [(IFExtendedDictionary *)self setObject:object forKey:key];
        return self;
    }
    return [self extendWith:[NSDictionary dictionaryWithObject:object forKey:key]];
}

@end

// A mutable dictionary class allowing one dictionary to be efficiently extended with a new set of values,
// without modifying the original dictionary.
@implementation IFExtendedDictionary

- (id)initWithParentDictionary:(NSDictionary *)parent {
    self = [super init];
    if (self) {
        parentDictionary = parent;
        selfDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)objectForKey:(id)aKey {
    id value = [selfDictionary objectForKey:aKey];
    if (!value) {
        value = [parentDictionary objectForKey:aKey];
    }
    return value;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [selfDictionary setObject:anObject forKey:aKey];
}

- (NSUInteger)count {
    return [[self allKeys] count];
}

- (NSEnumerator *)keyEnumerator {
    return [[self allKeys] objectEnumerator];
}

- (NSEnumerator *)objectEnumerator {
    return [[self allValues] objectEnumerator];
}

- (NSArray *)allValues {
    NSMutableSet *objects = [[NSMutableSet alloc] initWithArray:[parentDictionary allValues]];
    [objects addObjectsFromArray:[selfDictionary allValues]];
    return [objects allObjects];
}

- (NSArray *)allKeys {
    NSMutableSet *set = [[NSMutableSet alloc] initWithArray:[parentDictionary allKeys]];
    [set addObjectsFromArray:[selfDictionary allKeys]];
    return [set allObjects];
}

@end