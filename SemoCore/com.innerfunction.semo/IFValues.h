//
//  IFValues.h
//
//  Created by Julian Goacher on 16/07/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    IFValueTypeUndefined,
    IFValueTypeBoolean,
    IFValueTypeNumber,
    IFValueTypeString,
    IFValueTypeList,
    IFValueTypeObject
} IFValueType;

@protocol IFValues <NSObject>

// Return the bare value without any type conversion.
- (id)getValue:(NSString *)name;

// Test if a named property has a value.
- (BOOL)hasValue:(NSString *)name;

// Return a list of the top-level names in the values object.
- (NSArray *)getValueNames;

// Return the type of the specified value.
- (IFValueType)getValueType:(NSString *)name;

// Return the named property as a string.
- (NSString *)getValueAsString:(NSString *)name;
- (NSString *)getValueAsString:(NSString *)name defaultValue:(NSString *)defaultValue;

// Get a value as a localized string. The underlying string value should correspond to a resource ID
// in strings.xml, and the result is returned for the current platform locale.
// Returns the 'name' argument if the value can't be found.
- (NSString *)getValueAsLocalizedString:(NSString *)name;

// Return the named value as a number.
- (NSNumber *)getValueAsNumber:(NSString *)name;
- (NSNumber *)getValueAsNumber:(NSString *)name defaultValue:(NSNumber *)defaultValue;

// Return the named property as a boolean.
- (BOOL)getValueAsBoolean:(NSString *)name;
- (BOOL)getValueAsBoolean:(NSString *)name defaultValue:(BOOL)defaultValue;

// Return the named property as a date value.
- (NSDate *)getValueAsDate:(NSString *)name;
- (NSDate *)getValueAsDate:(NSString *)name defaultValue:(NSDate *)defaultValue;

// Return the named property as a colour value.
- (UIColor *)getValueAsColor:(NSString *)name;
- (UIColor *)getValueAsColor:(NSString *)name defaultValue:(UIColor *)defaultValue;

// Return the named property as a URL.
- (NSURL *)getValueAsURL:(NSString *)name;

// Return the named property as data.
- (NSData *)getValueAsData:(NSString *)name;

// Return the named property as an image.
- (UIImage *)getValueAsImage:(NSString *)name;

@end
