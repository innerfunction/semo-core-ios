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
#import "IFLogging.h"

@interface IFObjectConfigurer ()

/// Normalize a property name by removing any *ios- prefix. Returns nil for reserved names (e.g. *type etc.)
- (NSString *)normalizePropertyName:(NSString *)name;
/// Get type info for a named property of the object being configured.
- (IFPropertyInfo *)infoForProperty:(NSString *)name;
/// Get type hint info for members of the named collection property of the object being configured.
- (IFPropertyInfo *)getCollectionMemberTypeInfoForProperty:(NSString *)propName;
/// Test whether the argument is a collection configuration with type hints for its members.
- (BOOL)isCollectionWithTypeHints:(IFConfiguration *)configuration;

@end

#define KeyPath(name)   ([NSString stringWithFormat:@"%@.%@", _keyPath, name])

@implementation IFObjectConfigurer

- (id)initWithObject:(id)object inContainer:(IFContainer *)container keyPath:(NSString *)keyPath {
    self = [super init];
    if (self) {
        // NOTE that the object is replaced at this point with its configuration proxy, if any.
        // TODO: Confirm that this isn't needed (is applied instead by the container's newInstanceForClassName: method)
        //_object = [IFContainer applyConfigurationProxyWrapper:object];
        _object = object;
        _container = container;
        _typeInfo = [IFTypeInfo typeInfoForObject:_object];
        _keyPath = keyPath;
        _isCollection = [_object isKindOfClass:[NSArray class]] || [_object isKindOfClass:[NSDictionary class]];
    }
    return self;
}

- (id)initWithContainer:(IFContainer *)container {
    self = [super init];
    if (self) {
        _object = container;
        _container = container;
        _typeInfo = [IFTypeInfo typeInfoForObject:container];
        _collectionMemberTypeInfo = [IFPropertyInfo new];
        _keyPath = @"";
        _isCollection = YES;
    }
    return self;
}

- (void)configureWith:(IFConfiguration *)configuration {
    if ([_object conformsToProtocol:@protocol(IFIOCContainerAware)]) {
        [(id<IFIOCContainerAware>)_object beforeIOCConfiguration:configuration];
    }
    NSArray *valueNames = [configuration getValueNames];
    for (NSString *name in valueNames) {
        NSString *propName = [self normalizePropertyName:name];
        if (!propName) {
            continue;
        }
        [self configureProperty:propName withConfiguration:configuration];
    }
    // Post configuration.
    if ([_object conformsToProtocol:@protocol(IFIOCContainerAware)]) {
        NSValue *objectKey = [NSValue valueWithNonretainedObject:_object];
        if ([_container hasPendingValueRefsForObjectKey:objectKey]) {
            [_container recordPendingValueObjectConfiguration:configuration forObjectKey:objectKey];
        }
        else {
            [(id<IFIOCContainerAware>)_object afterIOCConfiguration:configuration];
        }
    }
    [_container doPostConfiguration:_object];
}

- (id)configureProperty:(NSString *)propName withConfiguration:(IFConfiguration *)configuration {
    id value = nil;
    IFPropertyInfo *propInfo = [self infoForProperty:propName];
    if (!propInfo) {
        return value;
    }
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
    }
    if (value == nil) {
        IFMaybeConfiguration *maybeConfig = [configuration getValueAsMaybeConfiguration:propName];
        IFConfiguration *valueConfig = maybeConfig.configuration;
        if (valueConfig) {
            // Flag indicating whether the resolved value should be configured in turn. Default is
            // yes, but some values will skip the configuration step.
            BOOL configureValue = YES;
            
            // If we have an item configuration with an instantiation hint then try using to build an object.
            // Note that instantiation hints take priority over in-place values, i.e. a configuration with
            // an instantiation hint will force build a new value even if there is already an in-place value.
            id factory = [valueConfig getValue:@"*factory"];
            if (factory) {
                // The configuration specifies an object factory, so resolve the factory object and attempt
                // using it to instantiate the object.
                if ([factory conformsToProtocol:@protocol(IFIOCObjectFactory)]) {
                    value = [(id<IFIOCObjectFactory>)factory buildObjectWithConfiguration:valueConfig
                                                                              inContainer:_container
                                                                               identifier:propName];
                    [_container doPostInstantiation:value];
                    [_container doPostConfiguration:value];
                }
                else {
                    DDLogError(@"%@: Invalid *factory class '%@', referenced at %@", LogTag, [factory class], KeyPath(propName));
                }
                // NOTE that factory instantiated objects do not go through the standard dependency-injection
                // configuration process (in the following 'else' block).
            }
            else {
                // Try instantiating object from type or class info.
                value = [_container instantiateObjectWithConfiguration:valueConfig identifier:propName];
                // Unable to instantiate a value, check for an in-place value.
                if (value == nil) {
                    @try {
                        value = [_object valueForKey:propName];
                    }
                    @catch (NSException *e) {
                        if (_isCollection && [@"NSUnknownKeyException" isEqualToString:e.name]) {
                            // Ignore: Can happen when e.g. configuring the container with named objects which
                            // aren't properties of the container.
                        }
                        else {
                            DDLogError(@"%@: Reading %@ %@", LogTag, KeyPath(propName), e);
                        }
                    }
                    // If value is a collection then we need a mutable copy before progressing.
                    if ([value isKindOfClass:[NSArray class]]) {
                        value = [(NSArray *)value mutableCopy];
                    }
                    else if ([value isKindOfClass:[NSDictionary class]]) {
                        value = [(NSDictionary *)value mutableCopy];
                    }
                    if (value != nil) {
                        // Apply configuration proxy wrapper, if any defined.
                        value = [IFContainer applyConfigurationProxyWrapper:value];
                    }
                }

                // If we get to this point and value is still nil then the following things are true:
                // a. The value config doesn't contain any instantiation hint.
                // b. The value config data is a collection (JSON object or list)
                // At this point we now decide whether to use the raw JSON data as the property value.
                // We do this if all of the following are true:
                // 1. The property is a collection type (NSArray or NSDictionary).
                // 2. The object owning the property provides no member type hint for the collection.
                //    (Other than for 'id' i.e. any generic object).
                // 3. The first item in the JSON collection doesn't provide any instantiation hint.
                // The last two points imply that without a type hint, the container can't instantiate new objects
                // from the collection's member data, so the data should be used as-is. Note however that this isn't
                // strictly true - the collection may contain deeply embedded object configurations that the
                // container could instantiate; however, the heuristic described here is applied as an efficiency
                // measure and will be correct in most cases. The measure can be overriden by the object being configured
                // if it returns a member type hint for the collection (i.e. via the IFIOCTypeInspectable protocol).
                // The type hint can be anything likely to be compatible - e.g. 'NSDictionary'.
                BOOL isArrayProp = [propInfo isMemberOrSubclassOf:[NSArray class]];
                BOOL isDictProp  = !isArrayProp && [propInfo isMemberOrSubclassOf:[NSDictionary class]];
                if (value == nil) {
                    BOOL isCollectionProp = (isArrayProp || isDictProp);
                    IFPropertyInfo *memberTypeInfo = [self getCollectionMemberTypeInfoForProperty:propName];
                    BOOL hasMemberInstantiationHints = [self isCollectionWithTypeHints:valueConfig];
                    if (isCollectionProp && [memberTypeInfo isId] && !hasMemberInstantiationHints) {
                        value = maybeConfig.data;
                        // The value should be treated as raw data (i.e. contains no configurables) so
                        // skip the configuration step.
                        configureValue = NO;
                    }
                }

                // Couldn't find an in-place value, so try instantiating a value.
                if (value == nil) {
                    if (isArrayProp) {
                        value = [NSMutableArray new];
                    }
                    else if (isDictProp) {
                        value = [NSMutableDictionary new];
                    }
                    else if (![propInfo isId]) {
                        // Try using the property info as a type hint. (But only if a specific type).
                        __unsafe_unretained Class propClass = [propInfo getPropertyClass];
                        NSString *className = NSStringFromClass(propClass);
                        @try {
                            value = [_container newInstanceForClassName:className withConfiguration:valueConfig];
                        }
                        @catch (NSException *e) {
                            DDLogInfo(@"%@: Error creating new instance of inferred type %@: %@", LogTag, className, e );
                        }
                    }
                }
                // If we have a value now and it should be configured then create a configurer for it.
                if (value != nil && configureValue) {
                    IFObjectConfigurer *configurer = [[IFObjectConfigurer alloc] initWithObject:value
                                                                                    inContainer:_container
                                                                                        keyPath:KeyPath(propName)];
                    // If dealing with a collection value then add type info for its members.
                    if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                        configurer->_collectionMemberTypeInfo = [self getCollectionMemberTypeInfoForProperty:propName];
                    }
                    // Configure the value.
                    [configurer configureWith:valueConfig];
                }
            }
        }
        // If still no value by this stage then try using whatever underlying value is in the maybe config.
        if (value == nil) {
            value = maybeConfig.bare;
        }
    }
    // If there is a value by this stage then inject into the object.
    if (value != nil) {
        value = [self injectValue:value intoProperty:propName];
    }
    return value;
}

- (id)injectValue:(id)value intoProperty:(NSString *)name {
    // Notify object aware values that they are about to be injected into the object under the current property name.
    // NOTE: This happens at this point - instead of after the value injection - so that value proxies can receive the
    // notification. It's more likely that proxies would implement this protocol than the values they act as proxy for
    // (i.e. because proxied values are likely to be standard platform classes).
    if ([value conformsToProtocol:@protocol(IFIOCObjectAware)]) {
        [(id<IFIOCObjectAware>)value notifyIOCObject:_object propertyName:name];
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
        IFPropertyInfo *propInfo = [self infoForProperty:name];
        if ([propInfo isWriteable] && [propInfo isAssignableFrom:[value class]]) {
            // Standard object property reference.
            [_object setValue:value forKey:name];
        }
        else if ([_object isKindOfClass:[NSDictionary class]]) {
            // Dictionary collection entry.
            _object[name] = value;
        }
        else if ([_object isKindOfClass:[NSArray class]]) {
            // Array item.
            NSMutableArray *array = (NSMutableArray *)_object;
            NSInteger idx = [name integerValue];
            // Add null items to pad array to the required length.
            for (NSInteger j = [array count]; j < idx + 1; j++) {
                [array addObject:[NSNull null]];
            }
            array[idx] = value;
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

- (IFPropertyInfo *)infoForProperty:(NSString *)propName {
    IFPropertyInfo *info = [_typeInfo infoForProperty:propName];
    if (!info && _isCollection) {
        info = _collectionMemberTypeInfo;
    }
    return info;
}

- (IFPropertyInfo *)getCollectionMemberTypeInfoForProperty:(NSString *)propName {
    if ([_object conformsToProtocol:@protocol(IFIOCTypeInspectable)]) {
        __unsafe_unretained Class memberClass = [(id<IFIOCTypeInspectable>)_object memberClassForCollection:propName];
        if (memberClass) {
            return [[IFPropertyInfo alloc] initWithClass:memberClass];
        }
    }
    // Can't resolve any class for the collection's members, return an all-type info.
    return [IFPropertyInfo new];
}

- (BOOL)isCollectionWithTypeHints:(IFConfiguration *)configuration {
    // Assume the configuration represents a collection of object configurations.
    // Inspect the first object configuration, and return true if the item contains
    // an instantiation hint. (The first item here is arbitrary).
    for (NSString *name in [configuration getValueNames]) {
        IFConfiguration *memberConfig = [configuration getValueAsConfiguration:name];
        if (memberConfig) {
            return [memberConfig hasValue:@"*type"]
                || [memberConfig hasValue:@"*ios-class"]
                || [memberConfig hasValue:@"*factory"];
        }
        else break;
    }
    return NO;
}

@end
