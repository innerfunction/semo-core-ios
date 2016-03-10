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
        _propertyType = [typeAttr substringFromIndex:1];
        
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
    return strcmp(_propertyType.UTF8String, @encode(BOOL)) == 0 || strcmp(_propertyType.UTF8String, @encode(Boolean)) == 0;
}

- (BOOL)isInteger {
    return strcmp(_propertyType.UTF8String, @encode(int)) == 0 || strcmp(_propertyType.UTF8String, @encode(NSInteger)) == 0;
}

- (BOOL)isFloat {
    return strcmp(_propertyType.UTF8String, @encode(float)) == 0 || strcmp(_propertyType.UTF8String, @encode(CGFloat)) == 0;
}

- (BOOL)isDouble {
    return strcmp(_propertyType.UTF8String, @encode(double)) == 0;
}

- (BOOL)isId {
    return strcmp(_propertyType.UTF8String, @encode(id)) == 0;
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

// Cache of class property sets, keyed by class name.
static NSMutableDictionary *IFTypeInfo_propertiesByClassName;
// Cache of type info instances, keyed by class name.
static NSMutableDictionary *IFTypeInfo_typeInfoCache;

+ (void)initialize {
    IFTypeInfo_propertiesByClassName = [NSMutableDictionary new];
    IFTypeInfo_typeInfoCache = [NSMutableDictionary new];
}

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
        Class class = [object class];
        NSString *className = NSStringFromClass(class);
        // Check for cached properties for the current object's class name.
        _properties = [IFTypeInfo_propertiesByClassName objectForKey:className];
        
        if (_properties == nil) {
            
            // No cached properties found, so start building a property set for the class hierarchy.
            _properties = [[NSMutableDictionary alloc] init];
            
            // Build an array of classes representing the class hierarchy, from sub-class to super-class.
            NSMutableArray *hierarchy = [NSMutableArray new];
            while (class) {
                [hierarchy addObject:class];
                class = [class superclass];
            }

            // See if cached properties exists for any class in the hierarchy, and if so then use the
            // result for the lowest (i.e. closest to the sub-class) class in the hierarchy with a cached
            // result.
            NSArray *classes = hierarchy; // The list of classes to later resolve properties for.
            for (NSInteger i = 0; i < [hierarchy count]; i++) {
                class = [hierarchy objectAtIndex:i];
                className = NSStringFromClass(class);
                // Check in the cache...
                NSDictionary *classProperties = [IFTypeInfo_propertiesByClassName objectForKey:className];
                // ...if cached properties found...
                if (classProperties) {
                    // ...then add the cached property set to the set of properties for this class...
                    [_properties addEntriesFromDictionary:classProperties];
                    // ...and remove the classes further up the hierarchy from the property search.
                    // This means that the property search below will only look for properties on the
                    // classes which inherit from the current class.
                    NSRange subrange = NSMakeRange(0, i);
                    classes = [hierarchy subarrayWithRange:subrange];
                    break;
                }
            }

            // Search for properties on the remaining classes in the class hierarchy.
            unsigned int propCount;
            // Property sets for each intermediate class remaining in the hierarchy are cached,
            // so process the classes in reverse order (i.e. super-class to sub-class order).
            for (Class class in [classes reverseObjectEnumerator]) {
                objc_property_t * props = class_copyPropertyList(class, &propCount);
                for (NSInteger i = 0; i < propCount; i++) {
                    objc_property_t prop = props[i];
                    
                    NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
                    
                    if ([propName isEqualToString:@"content"]) {
                        NSLog(@"!");
                    }
                    
                    // Skip nil property names.
                    if (propName == nil) continue;
                    
                    // Skip properties beginning with '_'; there are quite a lot of these on iOS core classes,
                    // and the presumably indicate private properties.
                    if ([propName hasPrefix:@"_"]) continue;
                    
                    // Otherwise map the property.
                    IFPropertyInfo *propInfo = [[IFPropertyInfo alloc] initWithProperty:prop];
                    [_properties setObject:propInfo forKey:propName];
                }
                
                // Add a copy of the property set to the cache.
                className = NSStringFromClass(class);
                [IFTypeInfo_propertiesByClassName setObject:[_properties copy] forKey:className];
            }
        }
        
        /*
        // Get properties for the current object's class and all its superclasses.
        _properties = [[NSMutableDictionary alloc] init];
        unsigned int propCount;
        Class c = [object class];
        while (c) {
            objc_property_t * props = class_copyPropertyList(c, &propCount);
            for (int i = 0; i < propCount; i++) {
                objc_property_t prop = props[i];
                
                NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
                
                // Skip nil property names.
                if (propName == nil) continue;
                
                // Skip properties beginning with '_'; there are quite a lot of these on iOS core classes,
                // and the presumably indicate private properties.
                if ([propName hasPrefix:@"_"]) continue;
                
                // Skip properties already mapped (i.e. properties overriden in a subclass).
                if ([_properties objectForKey:propName] != nil) continue;
                
                // Otherwise map the property.
                IFPropertyInfo *propInfo = [[IFPropertyInfo alloc] initWithProperty:prop];
                [_properties setObject:propInfo forKey:propName];
            }
            // Get the class' superclass
            c = [c superclass];
        }
        */
    }
    return self;
}

- (IFPropertyInfo *)infoForProperty:(NSString *)propName {
    return [_properties valueForKey:propName];
}

+ (IFTypeInfo *)typeInfoForObject:(id)object {
    NSString *className = NSStringFromClass([object class]);
    IFTypeInfo *typeInfo = [IFTypeInfo_typeInfoCache objectForKey:className];
    if (typeInfo == nil) {
        typeInfo = [[IFTypeInfo alloc] initWithObject:object];
        [IFTypeInfo_typeInfoCache setObject:typeInfo forKey:className];
    }
    return typeInfo;
}

+ (void)clearCache {
    [IFTypeInfo_propertiesByClassName removeAllObjects];
    [IFTypeInfo_typeInfoCache removeAllObjects];
}

@end
