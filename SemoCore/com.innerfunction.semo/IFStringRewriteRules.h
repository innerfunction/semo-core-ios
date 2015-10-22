//
//  IFStringRewriteRules.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFIOCTypeInspectable.h"
#import "IFRegExp.h"
#import "IFStringTemplate.h"

/** A single rewrite rule. */
@interface IFStringRewriteRule : NSObject {
    // A regexp compiled from the match pattern.
    IFRegExp *patternRegexp;
    // The result template.
    IFStringTemplate *resultTemplate;
}

/** A regexp pattern for matching strings to be rewritten. */
@property (nonatomic, strong) NSString *pattern;
/**
 * A string template for rewriting matched input strings.
 * Uses matching group numbers to insert values from the input string, e.g.
 *  /(http:.*)/ --> do:open+url={1}
 */
@property (nonatomic, strong) NSString *result;

/**
 * Attempt to rewrite a string using the current rule.
 * Returns a new string if the input can be rewritten, else returns nil.
 */
- (NSString *)rewriteString:(NSString *)str;

@end

/** A set of string rewrite rules. */
@interface IFStringRewriteRules : NSObject <IFIOCTypeInspectable>

/** A list of rewrite rules, in evaluation order. */
@property (nonatomic, strong) NSArray *rules;

/**
 * Attempt to rewrite a string.
 * Returns a new string which is the result of the first found rule that can rewrite the input,
 * or returns nil if no rule can rewrite the input.
 */
- (NSString *)rewriteString:(NSString *)str;

@end
