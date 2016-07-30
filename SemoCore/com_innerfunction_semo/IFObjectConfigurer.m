// Copyright 2016 InnerFunction Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Julian Goacher on 06/04/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFObjectConfigurer.h"
#import "IFContainer.h"
#import "IFIOCContainerAware.h"
#import "IFIOCTypeInspectable.h"
#import "IFIOCObjectFactory.h"
#import "IFIOCObjectAware.h"
#import "IFIOCProxy.h"
#import "IFPendingNamed.h"
#import "IFJSONData.h"
#import "IFLogging.h"

@interface IFObjectConfigurer ()

/// Normalize a property name by removing any *ios- prefix. Returns nil for reserved names (e.g. *type etc.)
- (NSString *)normalizePropertyName:(NSString *)name;

@end

/// A version of IFTypeInfo that returns type information for a collection's members.
@interface IFCollectionTypeInfo : IFTypeInfo {
    /// The default type of each member of the collection.
    IFPropertyInfo *_memberTypeInfo;
}

/**
 * Init the object.
 * @param collection    The collection.
 * @param propName      The name of the property the collection is bound to on its parent object.
 */
- (id)initWithCollection:(id)collection propName:(NSString *)propName;

@end

@implementation IFObjectConfigurer

- (id)initWithContainer:(IFContainer *)container {
    self = [super init];
    if (self) {
        _container = container;
    }
    return self;
}

- (void)configureWith:(IFConfiguration *)configuration {
    IFTypeInfo *typeInfo = [IFTypeInfo typeInfoForObject:_container];
    [self configureObject:_container withConfiguration:configuration typeInfo:typeInfo keyPathPrefix:@""];
}

- (void)configureObject:(id)object
      withConfiguration:(IFConfiguration *)configuration
               typeInfo:(IFTypeInfo *)typeInfo
          keyPathPrefix:(NSString *)kpPrefix {

    // Pre-configuration.
    if ([object conformsToProtocol:@protocol(IFIOCContainerAware)]) {
        [(id<IFIOCContainerAware>)object beforeIOCConfiguration:configuration];
    }
    // Iterate over each property name defined in the configuration.
    NSArray *valueNames = [configuration getValueNames];
    for (NSString *name in valueNames) {
        // Normalize the property name.
        NSString *propName = [self normalizePropertyName:name];
        if (propName) {
            // Get type info for the property.
            IFPropertyInfo *propInfo = [typeInfo infoForProperty:propName];
            if (!propInfo) {
                // If no type info then can't process this property any further.
                continue;
            }
            // Generate a key path reference for the property.
            NSString *kpRef;
            if (kpPrefix) {
                kpRef = [NSString stringWithFormat:@"%@.%@", kpPrefix, propName];
            }
            else {
                kpRef = propName;
            }
            // Build a property value from the configuration.
            id value = [self buildValueForObject:object
                                        property:propName
                               withConfiguration:configuration
                                        propInfo:propInfo
                                      keyPathRef:kpRef];
            // If there is a value by this stage then inject into the object.
            if (value != nil) {
                value = [self injectIntoObject:object value:value intoProperty:propName propInfo:propInfo];
            }
        }
    }
    // Post configuration.
    if ([object conformsToProtocol:@protocol(IFIOCContainerAware)]) {
        NSValue *objectKey = [NSValue valueWithNonretainedObject:object];
        if ([_container hasPendingValueRefsForObjectKey:objectKey]) {
            [_container recordPendingValueObjectConfiguration:configuration forObjectKey:objectKey];
        }
        else {
            [(id<IFIOCContainerAware>)object afterIOCConfiguration:configuration];
        }
    }
    [_container doPostConfiguration:object];
}

- (id)buildValueForObject:(id)object
                 property:(NSString *)propName
        withConfiguration:(IFConfiguration *)configuration
                 propInfo:(IFPropertyInfo *)propInfo
               keyPathRef:(NSString *)kpRef {
    
    id value = nil;
    
    // First, check to see if the property belongs to one of the standard types used to
    // represent primitive configurable values. These values are different to other
    // non-primitive types, in that (1) it's generally possible to convert values between them,
    // and (2) the code won't recursively perform any additional configuration on the values.
    if (![propInfo isId]) {
        // Primitives and core types.
        if ([propInfo isBoolean]) {
            value = [NSNumber numberWithBool:[configuration getValueAsBoolean:propName]];
        }
        else if ([propInfo isInteger]) {
            value = [configuration getValueAsNumber:propName];
        }
        else if ([propInfo isFloat]) {
            value = [configuration getValueAsNumber:propName];
        }
        else if ([propInfo isDouble]) {
            value = [configuration getValueAsNumber:propName];
        }
        else if ([propInfo isMemberOrSubclassOf:[NSNumber class]]) {
            value = [configuration getValueAsNumber:propName];
        }
        else if ([propInfo isMemberOrSubclassOf:[NSString class]]) {
            value = [configuration getValueAsString:propName];
        }
        else if ([propInfo isMemberOrSubclassOf:[NSDate class]]) {
            value = [configuration getValueAsDate:propName];
        }
        else if ([propInfo isMemberOrSubclassOf:[UIImage class]]) {
            value = [configuration getValueAsImage:propName];
        }
        else if ([propInfo isMemberOrSubclassOf:[UIColor class]]) {
            value = [configuration getValueAsColor:propName];
        }
        else if ([propInfo isMemberOrSubclassOf:[IFConfiguration class]]) {
            value = [configuration getValueAsConfiguration:propName];
        }
        else if ([propInfo isMemberOfClass:[IFJSONObject class]] || [propInfo isMemberOfClass:[IFJSONArray class]]) {
            // The IFJSONObject and IFJSONArray types are equivalent to NSDictionary and NSArray,
            // but their use allows a property to indicate that it will accept the raw JSON data
            // value, i.e. without further processing by this class.
            value = [configuration getValueAsJSONData:propName];
        }
    }
    
    // If value is still nil then the property is not a primitive or JSON data type. Try to
    // resolve a new value from the supplied configuration.
    // The configuration may contain a mixture of object definitions and fully instantiated
    // objects. The configuration's 'natural' representation will distinguish between these,
    // return a Configuration instance for object definitions and the actual object instance
    // otherwise.
    // When an object definition is returned, the property value is resolved according to the
    // following order of precedence:
    // 1. A configuration which supplies an instantiation hint - e.g. *type, *ios-class or
    //    *factory - and which successfully yields an object instance always takes precedence
    //    over other possible values;
    // 2. Next, any in-place value found by reading from the object property being configured;
    // 3. Finally, a value created by attempting to instantiate the declared type of the
    //    property being configured (i.e. the inferred type).
    if (value == nil) {
        // Fetch the configuration value's natural representation.
        value = [configuration getNatualValue:propName];
        if ([value isKindOfClass:[IFConfiguration class]]) {
            // The natural value contains a (potential) object definition, so attempt to
            // resolve the value from it.
            IFConfiguration *valueConfig = (IFConfiguration *)value;
            
            // Try asking the container to build a new object using the configuration. This
            // will only work if the configuration contains an instantiation hint (e.g. *type,
            // *factory etc.) and will return a non-null, fully-configured object if successful.
            value = [_container buildObjectWithConfiguration:valueConfig identifier:kpRef];
            if (value == nil) {
                // Couldn't build a value, so see if the object already has a value in-place.
                @try {
                    value = [object valueForKey:propName];
                }
                @catch (NSException *e) {
                    BOOL isCollection = [object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]];
                    if (isCollection && [@"NSUnknownKeyException" isEqualToString:e.name]) {
                        // Ignore: Can happen when e.g. configuring the container with named objects which
                        // aren't properties of the container.
                    }
                    else {
                        DDLogError(@"%@: Reading %@ %@", LogTag, kpRef, e);
                    }
                }
                if (value != nil) {
                    // Apply configuration proxy wrapper, if any defined, to the in-place value.
                    value = [IFContainer applyConfigurationProxyWrapper:value];
                }
                else if (![propInfo isId]) {
                    // No in-place value, so try inferring a value type from the property
                    // information, and then try to instantiate that type as the new value.
                    // (Note that the container method will return a configuration proxy for
                    // those classes which require one.)
                    __unsafe_unretained Class propClass = [propInfo getPropertyClass];
                    NSString *className = NSStringFromClass(propClass);
                    @try {
                        value = [_container newInstanceForClassName:className withConfiguration:valueConfig];
                    }
                    @catch (NSException *e) {
                        DDLogInfo(@"%@: Error creating new instance of inferred type %@: %@", LogTag, className, e );
                    }
                }
                // If we now have either an in-place or inferred type value by this point, then
                // continue by configuring the object with its configuration.
                if (value != nil) {
                    // If value is an NSDictionary or NSArray then get a mutable copy.
                    // Also, whilst at it - get type information for the object.
                    IFTypeInfo *typeInfo;
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        value = [(NSDictionary *)value mutableCopy];
                        typeInfo = [[IFCollectionTypeInfo alloc] initWithCollection:value propName:propName];
                    }
                    else if ([value isKindOfClass:[NSArray class]]) {
                        value = [(NSArray *)value mutableCopy];
                        typeInfo = [[IFCollectionTypeInfo alloc] initWithCollection:value propName:propName];
                    }
                    else {
                        typeInfo = [IFTypeInfo typeInfoForObject:object];
                    }
                    // Configure the value.
                    [self configureObject:value withConfiguration:valueConfig typeInfo:typeInfo keyPathPrefix:kpRef];
                }
                // If we get this far without a value then try returning the raw configuration data.
                else {
                    value = valueConfig.sourceData;
                }
            }
        }
    }
    return value;
}

- (id)injectIntoObject:(id)object value:(id)value intoProperty:(NSString *)name propInfo:(IFPropertyInfo *)propInfo {
    // Notify object aware values that they are about to be injected into the object under the current property name.
    // NOTE: This happens at this point - instead of after the value injection - so that value proxies can receive the
    // notification. It's more likely that proxies would implement this protocol than the values they act as proxy for
    // (i.e. because proxied values are likely to be standard platform classes).
    if ([value conformsToProtocol:@protocol(IFIOCObjectAware)]) {
        [(id<IFIOCObjectAware>)value notifyIOCObject:object propertyName:name];
    }
    // If value is a config proxy then unwrap the underlying value
    if ([value conformsToProtocol:@protocol(IFIOCProxy)]) {
        value = [(id<IFIOCProxy>)value unwrapValue];
    }
    // If value is a pending then defer operation until later.
    if ([value isKindOfClass:[IFPendingNamed class]]) {
        // Record the current property and object info, but skip further processing. The property value will be set
        // once the named reference is fully configured, see [IFContainer buildNamedObject:].
        IFPendingNamed *pending = (IFPendingNamed *)value;
        pending.key = name;
        pending.configurer = self;
        // Keep count of the number of pending value refs for the current object.
        [_container incPendingValueRefCountForPendingObject:pending];
    }
    else if (value != nil) {
        // Check for dictionary or map collections...
        if ([object isKindOfClass:[NSDictionary class]]) {
            // Dictionary collection entry.
            object[name] = value;
        }
        else if ([object isKindOfClass:[NSArray class]]) {
            // Array item.
            NSMutableArray *array = (NSMutableArray *)object;
            NSInteger idx = [name integerValue];
            // Add null items to pad array to the required length.
            for (NSInteger j = [array count]; j < idx + 1; j++) {
                [array addObject:[NSNull null]];
            }
            array[idx] = value;
        }
        else {
            // ...configuring an object which isn't a collection.
            if ([propInfo isWriteable] && [propInfo isAssignableFrom:[value class]]) {
                // Standard object property reference.
                [object setValue:value forKey:name];
            }
        }
    }
    return value;
}

#pragma mark - Private methods

- (NSString *)normalizePropertyName:(NSString *)name {
    if ([name hasPrefix:@"*"]) {
        if ([name hasPrefix:@"*ios-"]) {
            // Strip *ios- prefix from names.
            name = [name substringFromIndex:5];
            // Don't process class names.
            if ([@"class" isEqualToString:name]) {
                name = nil;
            }
        }
        else {
            name = nil; // Skip all other reserved names
        }
    }
    return name;
}

@end

@implementation IFCollectionTypeInfo

- (id)initWithCollection:(id)collection propName:(NSString *)propName {
    self = [super init];
    if (self) {
        if ([collection conformsToProtocol:@protocol(IFIOCTypeInspectable)]) {
            __unsafe_unretained Class memberClass = [(id<IFIOCTypeInspectable>)collection memberClassForCollection:propName];
            if (memberClass) {
                _memberTypeInfo = [[IFPropertyInfo alloc] initWithClass:memberClass];
            }
        }
        if (!_memberTypeInfo) {
            // Can't resolve any class for the collection's members, use an all-type info.
            _memberTypeInfo = [IFPropertyInfo new];
        }
    }
    return self;
}

- (IFPropertyInfo *)infoForProperty:(NSString *)propName {
    return _memberTypeInfo;
}

@end
