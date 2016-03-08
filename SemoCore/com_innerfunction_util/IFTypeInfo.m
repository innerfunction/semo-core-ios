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
        _propertyClass = nil;
        
        // Read property attributes.
        const char * chattr = property_getAttributes( property );
        
        // Convert to nsstring and tokenize
        NSString *nsattr = [NSString stringWithUTF8String:chattr];
        NSArray *attrs = [nsattr componentsSeparatedByString:@","];

        // Get the property type.
        NSString *typeAttr = [attrs firstObject];
        _propertyType = [[typeAttr substringFromIndex:1] UTF8String];
        
        // Try extracting class info.
        if ([typeAttr hasPrefix:@"T@"] && [typeAttr length] > 4) {
            // The type specifies a property type name in the form e.g. T@"NSData"
            // Note that if no class info is available then the attr will be just 'T@'
            NSRange range = NSMakeRange(3, [typeAttr length] - (1 + 3));
            NSString *className = [typeAttr substringWithRange:range];
            _propertyClass = NSClassFromString(className);
        }
        
        // Check for read-only flag.
        _isWriteable = ![attrs containsObject:@"R"];

    }
    return self;
}

- (BOOL)isBoolean {
    return strcmp(_propertyType, @encode(BOOL)) == 0 || strcmp(_propertyType, @encode(Boolean)) == 0;
}

- (BOOL)isInteger {
    return strcmp(_propertyType, @encode(int)) == 0 || strcmp(_propertyType, @encode(NSInteger)) == 0;
}

- (BOOL)isFloat {
    return strcmp(_propertyType, @encode(float)) == 0 || strcmp(_propertyType, @encode(CGFloat)) == 0;
}

- (BOOL)isDouble {
    return strcmp(_propertyType, @encode(double)) == 0;
}

- (BOOL)isId {
    return strcmp(_propertyType, @encode(id)) == 0;
}

- (BOOL)isAssignableFrom:(__unsafe_unretained Class)classObj {
    return [_propertyClass isSubclassOfClass:classObj];
}

- (__unsafe_unretained Class)getPropertyClass {
    return _propertyClass;
}

- (BOOL)isWriteable {
    return _isWriteable;
}

@end

@implementation IFTypeInfo

// TODO: Define a protocol that allows this class to directly interrogate an object for a list of
// configurable properties. The following can potentially be expensive (e.g. a table view having
// 150+ properties) and whilst chaching of type info objects by class name would avoid any performance
// issues, the full set of properties is not needed and having a protocol for declaring configurable
// properties would also help document the supported properties. Note that the protocol should define
// static methods on the class, and should be optional i.e. this class reverts to its original mode
// of operation if the object doesn't implement the protocol.
- (id)initWithObject:(id)object {
    self = [super init];
    if (self) {
        _properties = [[NSMutableDictionary alloc] init];
        unsigned int propCount;
        // Get properties for the current object's class and all its superclasses.
        Class c = [object class];
        while (c) {
            objc_property_t * props = class_copyPropertyList(c, &propCount);
            for (int i = 0; i < propCount; i++) {
                objc_property_t prop = props[i];
                NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
                IFPropertyInfo *propInfo = [[IFPropertyInfo alloc] initWithProperty:prop];
                [_properties setObject:propInfo forKey:propName];
            }
            // Get the class' superclass
            c = [c superclass];
        }
    }
    return self;
}

- (IFPropertyInfo *)infoForProperty:(NSString *)propName {
    return [_properties valueForKey:propName];
}

+ (IFTypeInfo *)typeInfoForObject:(id)object {
    // TODO: Caching of instances by class name.
    return [[IFTypeInfo alloc] initWithObject:object];
}

@end
