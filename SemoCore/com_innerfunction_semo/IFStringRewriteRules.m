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
        // Convert the array of matching groups to a dictionary whose
        // keys correspond to the group index.
        NSMutableDictionary *ctx = [[NSMutableDictionary alloc] init];
        for (NSInteger i = 0; i < [matches count]; i++) {
            NSString *key = [NSString stringWithFormat:@"%li", (long)i];
            [ctx setObject:[matches objectAtIndex:i] forKey:key];
        }
        // Use this dictionary as the template context.
        result = [resultTemplate render:ctx];
    }
    return result;
}

@end

@implementation IFStringRewriteRules

- (id)initWithConfiguration:(IFConfiguration *)config {
    self = [super init];
    if (self) {
        // If config doesn't have a 'rules' property then assume rules are defined
        // in compact format (i.e. the configs top level property names are the patterns,
        // mapped to the rewrite rules).
        if (![config hasValue:@"rules"]) {
            NSMutableArray *rules = [[NSMutableArray alloc] init];
            NSDictionary *ruleDefs = (NSDictionary *)config.data;
            for (NSString *pattern in ruleDefs) {
                IFStringRewriteRule *rule = [[IFStringRewriteRule alloc] init];
                rule.pattern = pattern;
                rule.result = [ruleDefs valueForKey:pattern];
                [rules addObject:rule];
            }
            _rules = rules;
        }
    }
    return self;
}

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
