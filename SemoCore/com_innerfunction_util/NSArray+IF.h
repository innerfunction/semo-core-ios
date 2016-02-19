//
//  NSArray+IF.h
//  EPCore
//
//  Created by Julian Goacher on 25/06/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (IF)

+ (NSArray *)arrayWithDictionaryKeys:(NSDictionary *)dictionary;

+ (NSArray *)arrayWithDictionaryValues:(NSDictionary *)dictionary forKeys:(NSArray *)keys;

+ (NSArray *)arrayWithItem:(id)item repeated:(NSInteger)repeats;

- (NSString *)joinWithSeparator:(NSString *)separator;

- (NSArray *)arrayWithoutItem:(id)item;

@end
