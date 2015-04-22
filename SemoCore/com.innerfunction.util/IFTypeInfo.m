//
//  IFPropertyType.m
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFTypeInfo.h"

@implementation IFPropertyInfo

- (id)initWithProperty:(objc_property_t)property {
    self = [super init];
    if (self) {
        const char * attr = property_getAttributes( property );
        int idx, len = strlen(attr);
        for (idx = 0; attr[idx] != ',' && idx < len; idx++);
        strncpy(propertyType, attr + 2, idx);
        propertyType[idx] = '\0';
        if (strncmp(propertyType, "T@", 2) == 0) {
            NSString *typeIdentifier = [NSString stringWithUTF8String:propertyType];
            propertyClass = NSClassFromString([typeIdentifier substringFromIndex:3]);
        }
        else {
            propertyClass = nil;
        }
    }
    return self;
}

- (BOOL)isBoolean {
    return strcmp(propertyType, @encode(BOOL)) == 0;
}

- (BOOL)isInteger {
    return strcmp(propertyType, @encode(int)) == 0;
}

- (BOOL)isFloat {
    return strcmp(propertyType, @encode(float)) == 0;
}

- (BOOL)isDouble {
    return strcmp(propertyType, @encode(double)) == 0;
}

- (BOOL)isAssignableFrom:(__unsafe_unretained Class)classObj {
    return [propertyClass isSubclassOfClass:classObj];
}

- (__unsafe_unretained Class)getPropertyClass {
    return propertyClass;
}

@end

@implementation IFTypeInfo

- (id)initWithObject:(id)object {
    self = [super init];
    if (self) {
        properties = [[NSMutableDictionary alloc] init];
        unsigned int propCount;
        objc_property_t * props = class_copyPropertyList([object class], &propCount);
        for (int i = 0; i < propCount; i++) {
            objc_property_t prop = props[i];
            NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
            IFPropertyInfo *propInfo = [[IFPropertyInfo alloc] initWithProperty:prop];
            [properties setObject:propInfo forKey:propName];
        }
    }
    return self;
}

- (IFPropertyInfo *)infoForProperty:(NSString *)propName {
    return [properties valueForKey:propName];
}

+ (IFTypeInfo *)typeInfoForObject:(id)object {
    // TODO: Caching of instances by class name.
    return [[IFTypeInfo alloc] initWithObject:object];
}

@end
