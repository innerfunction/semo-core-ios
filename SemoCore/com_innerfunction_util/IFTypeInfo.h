//
//  IFPropertyType.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface IFPropertyInfo : NSObject {
    char * propertyType;
    __unsafe_unretained Class propertyClass;
}

- (id)initWithProperty:(objc_property_t)property;
- (BOOL)isBoolean;
- (BOOL)isInteger;
- (BOOL)isFloat;
- (BOOL)isDouble;
- (BOOL)isId;
- (BOOL)isAssignableFrom:(__unsafe_unretained Class)classObj;
- (__unsafe_unretained Class)getPropertyClass;

@end

@interface IFTypeInfo : NSObject {
    NSMutableDictionary *properties;
}

- (id)initWithObject:(id)object;
- (IFPropertyInfo *)infoForProperty:(NSString *)propName;
+ (IFTypeInfo *)typeInfoForObject:(id)object;

@end
