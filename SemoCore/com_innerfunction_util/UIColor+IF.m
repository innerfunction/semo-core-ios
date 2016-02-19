//
//  UIColor+Hex.m
//  EventPacComponents
//
//  Created by Julian Goacher on 28/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "UIColor+IF.h"

@implementation UIColor (IF)

+ (UIColor *)colorForHex:(NSString *)hex {
	hex = [hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hex = [hex uppercaseString];
    if ([hex hasPrefix:@"#"]) {
        hex = [hex substringFromIndex:1];
    }
    if ([hex length] < 6) {
        return [UIColor clearColor];
    }
    // Separate into r, g, b substrings
    NSRange range;
    range.length = 2;
    range.location = 0;
    NSString *red = [hex substringWithRange:range];
    range.location = 2;
    NSString *green = [hex substringWithRange:range];
    range.location = 4;
    NSString *blue = [hex substringWithRange:range];
    unsigned int a = 1;
    if (hex.length == 8) {
        range.location = 6;
        [[NSScanner scannerWithString:[hex substringWithRange:range]] scanHexInt:&a];
    }
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:red] scanHexInt:&r];
    [[NSScanner scannerWithString:green] scanHexInt:&g];
    [[NSScanner scannerWithString:blue] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:(float)a];
}

@end
