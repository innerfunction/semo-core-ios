//
//  NSString+IF.h
//  EPCore
//
//  Created by Julian Goacher on 28/06/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IF)

- (NSInteger)indexOf:(NSString *)str;
- (NSString *)substringFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
- (NSArray *)split:(NSString *)pattern;
- (NSString *)replaceAllOccurrences:(NSString *)pattern with:(NSString *)string;

@end
