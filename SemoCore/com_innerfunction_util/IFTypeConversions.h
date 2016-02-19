//
//  IFTypeConversions.h
//  EventPacComponents
//
//  Created by Julian Goacher on 06/02/2014.
//  Copyright (c) 2014 InnerFunction. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Standard type conversions for the IFValues interface.
@interface IFTypeConversions : NSObject

/**
 * Convert value to a string:
 *  NSString -> NSString
 *  NSNumber -> [value stringValue]
 *  NSData -> [NSString initWithData:]
 *  * -> [value description]
 */
+ (NSString *)asString:(id)value;

/**
 * Convert value to a number:
 *  NSNumber -> NSNumber
 *  * -> nil
 */
+ (NSNumber *)asNumber:(id)value;

/**
 * Convert value to a boolean:
 *  NSNumber -> BOOL
 *  * -> NO
 */
+ (BOOL)asBoolean:(id)value;

/**
 * Convert value to a date:
 *  NSDate -> NSDate
 *  NSNumber -> NSDate (millisecond value)
 *  * -> NSString -> NSDate (ISO8601 value)
 */
+ (NSDate *)asDate:(id)value;

//+ (id)asJSONData:(id)value;

/**
 * Convert value to a URL:
 *  * -> NSString -> NSURL
 */
+ (NSURL *)asURL:(id)value;

/**
 * Convert value to data:
 *  * -> NSString -> NSData
 */
+ (NSData *)asData:(id)value;

/**
 * Convert value to an image:
 *  * -> NSString -> UIImage (string interpreted as image name; attempts to load -r4 images on 4 inch displays) 
 */
+ (UIImage *)asImage:(id)value;

/**
 * Convert the value to parsed JSON data.
 * Assumes the string representation of the value is valid JSON.
 * * -> NSData -> <parse JSON> -> id
 */
+ (id)asJSONData:(id)value;
   
/**
 * Convert to the named representation.
 * Recognized representation names are:
 * - string
 * - number
 * - boolean (returned as a number, to confirm with the return type).
 * - date
 * - url
 * - data
 * - image
 * - json
 * - default (returns the unchanged value).
 */
+ (id)value:(id)value asRepresentation:(NSString *)name;

@end
