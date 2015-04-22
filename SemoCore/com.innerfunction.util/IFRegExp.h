//
//  IFRegExp.h
//  EventPacComponents
//
//  Created by Julian Goacher on 10/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface IFRegExp : NSObject {
    NSRegularExpression *regex;
}

- (id)initWithPattern:(NSString *)pattern;
- (id)initWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (NSArray *)match:(NSString *)string;
- (NSRange)rangeOfFirstMatch:(NSString *)string;
- (BOOL)matches:(NSString *)string;
+ (BOOL)pattern:(NSString *)pattern matches:(NSString *)string;

@end
