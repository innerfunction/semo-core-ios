//
//  IFStringRewriteRules.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFStringRewriteRules.h"

@implementation IFStringRewriteRule

- (void)setPattern:(NSString *)pattern {
    _pattern = pattern;
    patternRegexp = [[IFRegExp alloc] initWithPattern:pattern];
}

- (void)setResult:(NSString *)result {
    _result = result;
    resultTemplate = [[IFStringTemplate alloc] initWithString:result];
}

- (NSString *)rewriteString:(NSString *)str {
    NSString *result = nil;
    NSArray *matches = [patternRegexp match:str];
    if (matches) {
        result = [resultTemplate render:matches];
    }
    return result;
}

@end

@implementation IFStringRewriteRules

- (Class)memberClassForCollection:(NSString *)propertyName {
    if ([@"rules" isEqualToString:propertyName]) {
        // Return the type class of the 'rules' array members.
        return [IFStringRewriteRule class];
    }
    return nil;
}

- (NSString *)rewriteString:(NSString *)str {
    NSString *result = nil;
    for (IFStringRewriteRule *rule in _rules) {
        result = [rule rewriteString:str];
        if (result) {
            break;
        }
    }
    return result;
}

@end
