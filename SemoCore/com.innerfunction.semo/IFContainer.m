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
            object = [self newInstanceForClassName:className];
        }
        else {
            DDLogCError(@"Make %@: No class name found for type %@", identifier, type);
        }
    }
    else {
        DDLogCError(@"Make %@: Component configuration missing 'semo:type' property", identifier);
    }
    return object;
}

- (id)newInstanceForClassName:(NSString *)className {
    return [[NSClassFromString(className) alloc] init];
}

- (void)configureObject:(id)object withConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier {
    if ([object conformsToProtocol:@protocol(IFConfigurable)]) {
        [(id<IFConfigurable>)object configure:configuration];
    }
    else {
        IFTypeInfo *typeInfo = [IFTypeInfo typeInfoForObject:object];
        if ([object conformsToProtocol:@protocol(IFIOCConfigurable)]) {
            [(id<IFIOCConfigurable>)object beforeConfigure:self];
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
            [(id<IFIOCConfigurable>)object afterConfigure:self];
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
    IFConfiguration *namedConfig = [configuration getValueAsConfiguration:@"named"];
    if (!namedConfig) {
        namedConfig = [configuration getValueAsConfiguration:@"names"];
    }
    if (namedConfig) {
        NSArray *names = [namedConfig getValueNames];
        NSMutableDictionary *objConfigs = [[NSMutableDictionary alloc] init];
        // Initialize named objects.
        for (NSString *name in names) {
            IFConfiguration *objConfig = [namedConfig getValueAsConfiguration:name];
            id object = [self instantiateObjectWithConfiguration:objConfig identifier:name];
            if (object) {
                [named setObject:object forKey:name];
                [objConfigs setObject:objConfig forKey:name];
            }
        }
        // Configure named objects.
        for (NSString *name in names) {
            id object = [named objectForKey:name];
            if (object) {
                IFConfiguration *objConfig = [objConfigs objectForKey:name];
                [self configureObject:object withConfiguration:objConfig identifier:name];
            }
        }
    }
}

- (id)resolveObjectPropertyOfType:(__unsafe_unretained Class)propClass
                fromConfiguration:(IFConfiguration *)configuration
                         withName:(NSString *)name {
    id object = [configuration getValue:name];
    if ([propClass isSubclassOfClass:[object class]]) {
        return object;
    }
    if ([configuration hasValue:[NSString stringWithFormat:@"%@.semo:type", name ]]) {
        IFConfiguration *propConfig = [configuration getValueAsConfiguration:name];
        return [self buildObjectWithConfiguration:propConfig identifier:name];
    }
    // No semo:type specified in configuration, so try instantiating an inferred type using the class information provided.
    NSString *className = NSStringFromClass(propClass);
    @try {
        object = [self newInstanceForClassName:className];
        [self configureObject:object withConfiguration:configuration identifier:name];
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
    for (id<IFService> service in services) {
        @try {
            [service stopService];
        }
        @catch (NSException *exception) {
            DDLogCError(@"Error stopping service %@: %@", [service class], exception);
        }
    }
    running = NO;
}

@end
