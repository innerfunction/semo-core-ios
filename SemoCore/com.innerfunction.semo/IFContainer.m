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
#import "IFIOCObjectFactory.h"
#import "IFTypeInfo.h"
#import "IFTypeConversions.h"
#import "IFLogging.h"

@interface IFContainer ()

/** Test if a configuration contains an instantiation hint, e.g. a type, class or factory specifier. */
- (BOOL)hasInstantiationHint:(IFConfiguration *)configuration;
/** Perform standard container-recognized protocol checks on a new object instance. */
- (void)doStandardProtocolChecks:(id)object;
/** Resolve an object property value compatible with the specified type from the specified configuration. */
- (id)resolveObjectPropertyOfType:(__unsafe_unretained Class)type
                fromConfiguration:(IFConfiguration *)configuration
                             name:(NSString *)name
                            value:(id)value;

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
    id object = nil;
    if ([configuration hasValue:@"*factory"]) {
        // The configuration specifies an object factory, so resolve the factory object and attempt
        // using it to instantiate the object.
        id factory = [configuration getValue:@"*factory"];
        if ([factory conformsToProtocol:@protocol(IFIOCObjectFactory)]) {
            object = [(id<IFIOCObjectFactory>)factory buildObjectWithConfiguration:configuration inContainer:self identifier:identifier];
            [self doStandardProtocolChecks:object];
        }
        else {
            DDLogError(@"%@: Building %@, invalid factory class '%@'", LogTag, identifier, [factory class]);
        }
    }
    else {
        // Try instantiating object from type or class info.
        object = [self instantiateObjectWithConfiguration:configuration identifier:identifier];
        if (object) {
            // Configure the resolved object.
            [self configureObject:object withConfiguration:configuration identifier:identifier];
        }
    }
    return object;
}

- (id)instantiateObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier {
    id object = nil;
    NSString *className = [configuration getValueAsString:@"*ios-class"];
    if (!className) {
        NSString *type = [configuration getValueAsString:@"*type"];
        if (type) {
            className = [types getValueAsString:type];
            if (!className) {
                DDLogError(@"%@: Making %@, no class name found for type %@", LogTag, identifier, type);
            }
        }
        else {
            DDLogError(@"%@: Making %@, Component configuration missing *type or *ios-class property", LogTag, identifier);
        }
    }
    if (className) {
        object = [self newInstanceForClassName:className withConfiguration:configuration];
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
    [self doStandardProtocolChecks:instance];
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
            if ([name hasPrefix:@"*"]) {
                if ([name hasPrefix:@"*ios-"]) {
                    // Strip *ios- prefix from names.
                    propName = [name substringFromIndex:5];
                    // Don't process class names.
                    if ([@"class" isEqualToString:propName]) {
                        continue;
                    }
                }
                else if ([name hasPrefix:@"*"]) {
                    continue; // Skip all other reserved names
                }

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
                                                                    name:[NSString stringWithFormat:@"%@.%ld", propName, (long)idx]
                                                                   value:nil];
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
                        id propValue = [self resolveObjectPropertyOfType:propertyClass fromConfiguration:propConfigs name:valueName value:nil];
                        if (propValue) {
                            [propValues setObject:propValue forKey:valueName];
                        }
                    }
                    value = propValues;
                }
            }
            else {
                __unsafe_unretained Class propClass = [propertyInfo getPropertyClass];
                id propValue = [object valueForKey:propName];
                value = [self resolveObjectPropertyOfType:propClass fromConfiguration:configuration name:propName value:propValue];
            }
            if (value != nil) {
                [object setValue:value forKey:propName];
            }
        }
        if ([object conformsToProtocol:@protocol(IFIOCConfigurable)]) {
            [(id<IFIOCConfigurable>)object afterConfiguration:configuration inContainer:self];
        }
        // If running and the object is a service instance then start the service now that it is fully configured.
        if (running && [object conformsToProtocol:@protocol(IFService)]) {
            [(id<IFService>)object startService];
        }
    }
}

- (void)configureWith:(IFConfiguration *)configuration {
    // Type info for the container's properties - allows type inferring of named properties.
    IFTypeInfo *typeInfo = [IFTypeInfo typeInfoForObject:self];
    // Add named objects.
    NSArray *names = [configuration getValueNames];
    NSMutableDictionary *objConfigs = [[NSMutableDictionary alloc] init];
    // Initialize named objects.
    for (NSString *name in names) {
        id value = [configuration getValue:name];
        if ([value isKindOfClass:[NSDictionary class]]) {
            value = [configuration getValueAsConfiguration:name];
        }
        if ([value isKindOfClass:[IFConfiguration class]]) {
            // Try instantiating a new object from an object configuration.
            IFConfiguration *objConfig = [(IFConfiguration *)value normalize];
            id object = nil;
            // Try instantating directly from the configuration.
            if ([self hasInstantiationHint:objConfig]) {
                object = [self instantiateObjectWithConfiguration:objConfig identifier:name];
            }
            // If no object then check for a container property with the same name, and try to infer a type.
            if (!object) {
                IFPropertyInfo *propertyInfo = [typeInfo infoForProperty:name];
                if (propertyInfo) {
                    __unsafe_unretained Class propClass = [propertyInfo getPropertyClass];
                    NSString *propClassName = NSStringFromClass(propClass);
                    object = [self newInstanceForClassName:propClassName withConfiguration:objConfig];
                }
            }
            // If object then record its configuration.
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
        // If the named object corresponds to a property on the container then try setting that property.
        IFPropertyInfo *propertyInfo = [typeInfo infoForProperty:name];
        if (propertyInfo && [propertyInfo isAssignableFrom:[object class]]) {
            [self setValue:object forKey:name];
        }
    }
}

- (void)configureWithData:(id)configData {
    IFConfiguration *configuration = [[IFConfiguration alloc] initWithData:configData];
    [self configureWith:configuration];
}

#pragma mark - Private methods

- (BOOL)hasInstantiationHint:(IFConfiguration *)configuration {
    return [configuration hasValue:@"*type"] || [configuration hasValue:@"*ios-class"] || [configuration hasValue:@"*factory"];
}

- (void)doStandardProtocolChecks:(id)object {
    // If the new instance is container aware then pass reference to this container.
    if ([object conformsToProtocol:@protocol(IFIOCContainerAware)]) {
        ((id<IFIOCContainerAware>)object).iocContainer = self;
    }
    // If instance is a service then add to list of services.
    if ([object conformsToProtocol:@protocol(IFService)]) {
        [services addObject:(id<IFService>)object];
    }
}

- (id)resolveObjectPropertyOfType:(__unsafe_unretained Class)propClass
                fromConfiguration:(IFConfiguration *)configuration
                             name:(NSString *)name
                            value:(id)value {
    id object = [configuration getValue:name];
    IFConfiguration *propConfig = nil;
    // If object is a dictionary then try resolving an object using the configuration.
    if ([object isKindOfClass:[NSDictionary class]]) {
        propConfig = [[configuration getValueAsConfiguration:name] normalize];
        // Build and return the object if the configuration contains an instantiation hint.
        if ([self hasInstantiationHint:propConfig]) {
            return [self buildObjectWithConfiguration:propConfig identifier:name];
        }
        else if (value != nil) {
            // No instantiation hints on the configuration, but the property already has a
            // value so try configuring that instead.
            [self configureObject:value withConfiguration:propConfig identifier:name];
            // The property value doesn't need to be set, so return nil.
            return nil;
        }
    }
    // See if object type is compatible with the property.
    if ([[object class] isSubclassOfClass:propClass]) {
        return object;
    }
    // Unpack the object if packaged into a resource.
    if ([object isKindOfClass:[IFResource class]]) {
        // TODO: Should we instead recurse into this method with the unpacked resource value?
        object = ((IFResource *)object).data;
    }
    // Try setting property again.
    if ([[object class] isSubclassOfClass:propClass]) {
        return object;
    }
    // If a configuration was found but no type or class info specified then try instantiating an object using the
    // configuration and inferred type information.
    if (propConfig) {
        NSString *className = NSStringFromClass(propClass);
        @try {
            object = [self newInstanceForClassName:className withConfiguration:propConfig];
            [self configureObject:object withConfiguration:propConfig identifier:name];
            return object;
        }
        @catch (NSException *exception) {
            DDLogCInfo(@"Failed to instantiate instance of inferred type %@: %@", className, exception);
        }
    }
    // Unable to instantiate an object of a compatible type, so return nil.
    return nil;
}

#pragma mark - IFService

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

#pragma mark - IFConfigurationRoot

- (id)getValue:(NSString *)name asRepresentation:(NSString *)representation {
    id value = [self getNamed:name];
    if (value && ![@"bare" isEqualToString:representation]) {
        value = [IFTypeConversions value:value asRepresentation:representation];
    }
    return value;
}

@end
