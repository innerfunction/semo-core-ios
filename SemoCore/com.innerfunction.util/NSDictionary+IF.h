//
//  NSDictionary+IF.h
//  EPCore
//
//  Created by Julian Goacher on 21/06/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (IF)

/**
 * Return a new dictionary composed of the values in the current dictionary, plus the values in the argument.
 * Both the self and argument dictionarys are unchanged.
 */
- (NSDictionary *)extendWith:(NSDictionary *)values;

/**
 * Return a dictionary with the specified key/value pair added.
 * Modifies the self dictionary if possible, otherwise returns a new copy of the self dictionary with the key/pair added.
 */
- (NSDictionary *)dictionaryWithAddedObject:(id)object forKey:(id)key;

@end
