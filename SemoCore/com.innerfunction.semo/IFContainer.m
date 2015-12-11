//
//  IFContainer.m
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFContainer.h"
#import "IFConfigurable.h"
#import "IFIOCConfigurable.h"
#import "IFIOCTypeInspectable.h"
#import "IFIOCConfigurationInitable.h"
#import "IFIOCContainerAware.h"
#import "IFTypeInfo.h"
#import "IFLogging.h"

@interface IFContainer ()

- (id)resolveObjectPropertyOfType:(__unsafe_unretained Class)type
                fromConfiguration:(IFConfiguration *)configuration
                         withName:(NSString *)name;

@end

@implementation IFContainer

- (id)init {
    self = [super init];
    if (self) {
        named = [[NSMutableDictionary alloc] init];
        services = [[NSMutableArray alloc] init];
        types = [IFConfiguration emptyConfiguration];
        running = NO;
    }
    return self;
}

- (id)getNamed:(NSString *)name {
    return [named objectForKey:name];
}

- (void)setTypes:(IFConfiguration *)_types {
    types = _types ? _types : [IFConfiguration emptyConfiguration];
}

- (void)addTypes:(id)_types {
    if (_types) {
        IFConfiguration *typeConfig;
        if ([_types isKindOfClass:[IFConfiguration class]]) {
            typeConfig = (IFConfiguration *)_types;
        }
        else {
            typeConfig = [[IFConfiguration alloc] initWithData:_types];
        }
        types = [types mergeConfiguration:typeConfig];
    }
}

- (id)buildObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier {
    configuration = [configuration normalize];
    id object = [self instantiateObjectWithConfiguration:configuration identifier:identifier];
    if (object) {
        [self configureObject:object withConfiguration:configuration identifier:identifier];
    }
    return object;
}

- (id)instantiateObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier {
    id object = nil;
    NSString *type = [configuration getValueAsString:@"semo:type"];
    if (type) {
        NSString *className = [types getValueAsString:type];
        if (className) {
            object = [self newInstanceForClassName:className withConfiguration:configuration];
        }
        else {
            DDLogError(@"%@: Making %@, no class name found for type %@", LogTag, identifier, type);
        }
    }
    else {
        DDLogError(@"%@: Making %@, Component configuration missing 'semo:type' property", LogTag, identifier);
    }
    return object;
}

- (id)newInstanceForClassName:(NSString *)className withConfiguration:(IFConfiguration *)configuration {
    id instance = [NSClassFromString(className) alloc];
    if ([instance conformsToProtocol:@protocol(IFIOCConfigurationInitable)]) {
        instance = [(id<IFIOCConfigurationInitable>)instance initWithConfiguration:configuration];
    }
    else {
        instance = [instance init];
    }
    if ([instance conformsToProtocol:@protocol(IFIOCContainerAware)]) {
        ((id<IFIOCContainerAware>)instance).iocContainer = self;
    }
    return instance;
}

- (id)newInstanceForTypeName:(NSString *)typeName withConfiguration:(IFConfiguration *)configuration {
    NSString *className = [types getValueAsString:typeName];
    if (!className) {
        DDLogError(@"%@: newInstanceForTypeName, no class name found for type %@", LogTag, typeName);
        return nil;
    }
    return [self newInstanceForClassName:className withConfiguration:configuration];
}

- (void)configureObject:(id)object withConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier {
    if ([object conformsToProtocol:@protocol(IFConfigurable)]) {
        [(id<IFConfigurable>)object configure:configuration];
    }
    else {
        IFTypeInfo *typeInfo = [IFTypeInfo typeInfoForObject:object];
        if ([object conformsToProtocol:@protocol(IFIOCConfigurable)]) {
            [(id<IFIOCConfigurable>)object beforeConfiguration:configuration inContainer:self];
        }
        id<IFIOCTypeInspectable> typeInspectable = nil;
        if ([object conformsToProtocol:@protocol(IFIOCTypeInspectable)]) {
            typeInspectable = (id<IFIOCTypeInspectable>)object;
        }
        for (NSString *name in [configuration getValueNames]) {
            NSString *propName = name;
            if ([name hasPrefix:@"and:"] || [name hasPrefix:@"semo:"]) {
                continue; // Skip names starting with and: or semo:
            }
            if ([name hasPrefix:@"ios:"]) {
                // Strip ios: prefix from names.
                propName = [name substringFromIndex:4];
            }
            IFPropertyInfo *propertyInfo = [typeInfo infoForProperty:propName];
            if (!propertyInfo) {
                continue;
            }
            id value = nil;
            if ([propertyInfo isBoolean]) {
                value = [NSNumber numberWithBool:[configuration getValueAsBoolean:propName]];
            }
            else if ([propertyInfo isInteger]) {
                value = [configuration getValueAsNumber:propName];
            }
            else if ([propertyInfo isFloat]) {
                value = [configuration getValueAsNumber:propName];
            }
            else if ([propertyInfo isDouble]) {
                value = [configuration getValueAsNumber:propName];
            }
            else if ([propertyInfo isId]) {
                value = [configuration getValue:propName];
            }
            else if ([propertyInfo isAssignableFrom:[NSNumber class]]) {
                value = [configuration getValueAsNumber:propName];
            }
            else if ([propertyInfo isAssignableFrom:[NSString class]]) {
                value = [configuration getValueAsString:propName];
            }
            else if ([propertyInfo isAssignableFrom:[NSDate class]]) {
                value = [configuration getValueAsDate:propName];
            }
            else if ([propertyInfo isAssignableFrom:[UIImage class]]) {
                value = [configuration getValueAsImage:propName];
            }
            else if ([propertyInfo isAssignableFrom:[UIColor class]]) {
                value = [configuration getValueAsColor:propName];
            }
            else if ([propertyInfo isAssignableFrom:[IFResource class]]) {
                value = [configuration getValueAsResource:propName];
            }
            else if ([propertyInfo isAssignableFrom:[IFConfiguration class]]) {
                value = [configuration getValueAsConfiguration:propName];
            }
            else if ([propertyInfo isAssignableFrom:[NSArray class]]) {
                if ([configuration getValueType:propName] == IFValueTypeList) {
                    NSArray *list = (NSArray *)[configuration getValue:propName];
                    NSInteger length = [list count];
                    NSMutableArray *propValues = [[NSMutableArray alloc] initWithCapacity:length];
                    __unsafe_unretained Class propertyClass = [typeInspectable memberClassForCollection:propName];
                    if (!propertyClass) {
                        propertyClass = [NSObject class];
                    }
                    for (NSInteger idx = 0; idx < length; idx++) {
                        id propValue = [self resolveObjectPropertyOfType:propertyClass
                                                       fromConfiguration:configuration
                                                                withName:[NSString stringWithFormat:@"%@.%ld", propName, (long)idx]];
                        [propValues addObject:propValue];
                    }
                    value = propValues;
                }
            }
            else if ([propertyInfo isAssignableFrom:[NSDictionary class]]) {
                IFConfiguration *propConfigs = [configuration getValueAsConfiguration:propName];
                if (propConfigs) {
                    NSMutableDictionary *propValues = [[NSMutableDictionary alloc] init];
                    __unsafe_unretained Class propertyClass = [typeInspectable memberClassForCollection:propName];
                    if (!propertyClass) {
                        propertyClass = [NSObject class];
                    }
                    for (NSString *valueName in [propConfigs getValueNames]) {
                        id propValue = [self resolveObjectPropertyOfType:propertyClass fromConfiguration:propConfigs withName:valueName];
                        if (propValue) {
                            [propValue setObject:propValue forKey:valueName];
                        }
                    }
                    value = propValues;
                }
            }
            else {
                __unsafe_unretained Class propertyClass = [propertyInfo getPropertyClass];
                value = [self resolveObjectPropertyOfType:propertyClass fromConfiguration:configuration withName:propName];
            }
            [object setValue:value forKey:propName];
        }
        if ([object conformsToProtocol:@protocol(IFIOCConfigurable)]) {
            [(id<IFIOCConfigurable>)object afterConfiguration:configuration inContainer:self];
        }
        // If the object instance is a service then add to the list of services, and start the
        // service if the container services are running.
        if ([object conformsToProtocol:@protocol(IFService)]) {
            id<IFService> service = (id<IFService>)object;
            [services addObject:service];
            if (running) {
                [service startService];
            }
        }
    }
}

- (void)configureWith:(IFConfiguration *)configuration {
    // Add named objects.
    NSArray *names = [configuration getValueNames];
    NSMutableDictionary *objConfigs = [[NSMutableDictionary alloc] init];
    // Initialize named objects.
    for (NSString *name in names) {
        id value;
        IFValueType valueType = [configuration getValueType:name];
        if (valueType == IFValueTypeObject) {
            value = [configuration getValueAsConfiguration:name];
        }
        else {
            value = [configuration getValue:name];
        }
        if ([value isKindOfClass:[IFConfiguration class]]) {
            // Try instantiating a new object from an object configuration.
            IFConfiguration *objConfig = [(IFConfiguration *)value normalize];
            id object = [self instantiateObjectWithConfiguration:objConfig identifier:name];
            if (object) {
                value = object;
                [objConfigs setObject:objConfig forKey:name];
            }
        }
        if (value) {
            [named setObject:value forKey:name];
        }
    }
    // Configure named objects.
    for (NSString *name in names) {
        id object = [named objectForKey:name];
        IFConfiguration *objConfig = [objConfigs objectForKey:name];
        if (object && objConfig) {
            [self configureObject:object withConfiguration:objConfig identifier:name];
        }
    }
}

- (void)configureWithData:(id)configData {
    IFConfiguration *configuration = [[IFConfiguration alloc] initWithData:configData];
    [self configureWith:configuration];
}

- (id)resolveObjectPropertyOfType:(__unsafe_unretained Class)propClass
                fromConfiguration:(IFConfiguration *)configuration
                         withName:(NSString *)name {
    id object = [configuration getValue:name];
    if ([propClass isSubclassOfClass:[object class]]) {
        return object;
    }
    // Try instantiating an object from the configuration.
    IFConfiguration *propConfig = [[configuration getValueAsConfiguration:name] normalize];
    // Check if the property configuration includes a type.
    if ([propConfig hasValue:@"semo:type"]) {
        return [self buildObjectWithConfiguration:propConfig identifier:name];
    }
    // No semo:type specified in configuration, so try instantiating an inferred type using the class information provided.
    NSString *className = NSStringFromClass(propClass);
    @try {
        object = [self newInstanceForClassName:className withConfiguration:propConfig];
        [self configureObject:object withConfiguration:propConfig identifier:name];
    }
    @catch (NSException *exception) {
        DDLogCInfo(@"Failed to instantiate instance of inferred type %@: %@", className, exception);
    }
    return object;
}

- (void)startService {
    running = YES;
    for (id<IFService> service in services) {
        @try {
            [service startService];
        }
        @catch (NSException *exception) {
            DDLogCError(@"Error starting service %@: %@", [service class], exception);
        }
    }
}

- (void)stopService {
    SEL stopService = @selector(stopService);
    for (id<IFService> service in services) {
        @try {
            if ([service respondsToSelector:stopService]) {
                [service stopService];
            }
        }
        @catch (NSException *exception) {
            DDLogCError(@"Error stopping service %@: %@", [service class], exception);
        }
    }
    running = NO;
}

@end
