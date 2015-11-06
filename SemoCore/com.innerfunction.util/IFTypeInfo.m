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
        // Read property attributes.
        const char * attr = property_getAttributes( property );
        
        // Find index of end of type information in attribute string.
        int idx, len = (int)strlen(attr);
        for (idx = 0; attr[idx] != ',' && idx < len; idx++);
        
        // Copy type info to its own var.
        propertyType = malloc(idx - 1);
        strncpy(propertyType, attr + 1, idx);
        propertyType[idx - 1] = '\0';
        
        // Try extracting class info from the type info.
        if (strncmp(propertyType, "@", 1) == 0 && idx > 3) {
            // The type identified includes quotes around the class name, e.g. T@"NSData", so extract the class name from
            // within the quotes. The length is idx - 4 because (i) the end index is idx - 2; (ii) + 2 for the start offset.
            NSString *className = [[NSString stringWithUTF8String:propertyType] substringWithRange:NSMakeRange(2, idx - 4)];
            propertyClass = NSClassFromString(className);
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

- (BOOL)isId {
    return strcmp(propertyType, @encode(id)) == 0;
}

- (BOOL)isAssignableFrom:(__unsafe_unretained Class)classObj {
    return [propertyClass isSubclassOfClass:classObj];
}

- (__unsafe_unretained Class)getPropertyClass {
    return propertyClass;
}

- (void)dealloc {
    free(propertyType);
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
