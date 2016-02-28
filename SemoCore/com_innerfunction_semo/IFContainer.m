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
#import "IFPostScheme.h"
#import "IFTypeConversions.h"
#import "IFLogging.h"

@interface IFContainer ()

/** Test if a configuration contains an instantiation hint, e.g. a type, class or factory specifier. */
- (BOOL)hasInstantiationHint:(IFConfiguration *)configuration;
/** Resolve an object property value compatible with the specified type from the specified configuration. */
- (id)resolveObjectPropertyOfType:(__unsafe_unretained Class)type
                fromConfiguration:(IFConfiguration *)configuration
                             name:(NSString *)name
                            value:(id)value;
// Instantiate and configure a named object.
- (id)buildNamedObject:(NSString *)name;

@end

@implementation IFContainer

- (id)init {
    self = [super init];
    if (self) {
        _named = [[NSMutableDictionary alloc] init];
        _services = [[NSMutableArray alloc] init];
        _types = [IFConfiguration emptyConfiguration];
        _running = NO;
        _propertyTypeInfo = [IFTypeInfo typeInfoForObject:self];
        _pendingNames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setTypes:(IFConfiguration *)types {
    _types = _types ? _types : [IFConfiguration emptyConfiguration];
}

- (void)addTypes:(id)types {
    if (types) {
        IFConfiguration *typeConfig;
        if ([types isKindOfClass:[IFConfiguration class]]) {
            typeConfig = (IFConfiguration *)types;
        }
        else {
            typeConfig = [[IFConfiguration alloc] initWithData:types];
        }
        _types = [_types mergeConfiguration:typeConfig];
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
            className = [_types getValueAsString:type];
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
    NSString *className = [_types getValueAsString:typeName];
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
        if (_running && [object conformsToProtocol:@protocol(IFService)]) {
            [(id<IFService>)object startService];
        }
    }
}

// Configure the container with the specified configuration.
// The container performs implicit dependency ordering. This means that if an object A has a dependency
// on another object B, then B will be built (instantiated & configured) before A. This will work for an
// arbitary length dependency chain (e.g. A -> B -> C -> etc.)
// Implicit dependency ordering relies on the fact that dependencies like this can only be specified using
// the named: URI scheme, which uses the container's getNamed: method to resolve named objects.
// The configuration process works as follows:
// * This method iterates over each named object configuration and builds each object in turn.
// * If any named object has a dependency on another named object then this will be resolved via the named:
//   URI scheme and the container's getNamed: method.
// * In the getNamed: method, if a name isn't found but a configuration exists then the container will
//   attempt to build and return the named object. This means that in effect, building of an object is
//   temporarily suspended whilst building of its dependency is prioritized. This process will recurse
//   until the full dependency chain is resolved.
// * The container maintains a stack of names being built. This allows the container to detect dependency
//   cycles and so avoid infinite regression. Dependency cycles cannot be fully resolved, and the last
//   dependency in a cycle will resolve to nil.
- (void)configureWith:(IFConfiguration *)configuration {
    _containerConfig = configuration;
    // Iterate over named object configs and build each object.
    NSArray *names = [_containerConfig getValueNames];
    for (NSString *name in names) {
        // Build the object only if it has not already been built and added to _named.
        // (Objects which are dependencies of other objects may be configured via getNamed:
        // before this loop has iterated around to them).
        if ([_named objectForKey:name] == nil) {
            [self buildNamedObject:name];
        }
    }
}

// Build a named object from the available configuration and property type info.
- (id)buildNamedObject:(NSString *)name {
    // Track that we're about to build this name.
    [_pendingNames addObject:name];
    // Resolve the object's configuration.
    id object = [_containerConfig getValue:name];
    IFPropertyInfo *propertyInfo = [_propertyTypeInfo infoForProperty:name];
    if ([object isKindOfClass:[NSDictionary class]]) {
        object = [_containerConfig getValueAsConfiguration:name];
    }
    if ([object isKindOfClass:[IFConfiguration class]]) {
        // Try instantiating a new object from an object configuration.
        IFConfiguration *objConfig = [(IFConfiguration *)object normalize];
        // Try instantating directly from the configuration.
        if ([self hasInstantiationHint:objConfig]) {
            object = [self buildObjectWithConfiguration:objConfig identifier:name];
        }
        else {
            // If no instantiation hint then check for a container property with the same name, and try to infer a type.
            if (propertyInfo) {
                __unsafe_unretained Class propClass = [propertyInfo getPropertyClass];
                NSString *propClassName = NSStringFromClass(propClass);
                object = [self newInstanceForClassName:propClassName withConfiguration:objConfig];
                [self configureObject:object withConfiguration:objConfig identifier:name];
            }
            else {
                // Can't instantiate object, but add the configuration to named.
                object = objConfig;
            }
        }
    }
    if (object != nil) {
        [_named setObject:object forKey:name];
        // If the named object corresponds to a property on the container then try setting that property.
        if (propertyInfo && [propertyInfo isAssignableFrom:[object class]]) {
            [self setValue:object forKey:name];
        }
    }
    // Finished building the current name, remove from list.
    [_pendingNames removeLastObject];
    return object;
}

// Get a named object. Will attempt building the object if necessary.
- (id)getNamed:(NSString *)name {
    id object = [_named objectForKey:name];
    // If named object not found then consider whether to try building it.
    if (object == nil) {
        // Check for a dependency cycle.
        if ([_pendingNames containsObject:name]) {
            NSLog(@"WARNING: Named dependency cycle detected %@ -> %@", [_pendingNames componentsJoinedByString:@" -> "], name);
        }
        else if ([_containerConfig hasValue:name]) {
            NSLog(@"IDO: Prioritizing building of named %@ -> %@", [_pendingNames componentsJoinedByString:@"."], name);
            // The container config contains a configuration for the wanted name, but _named doesn't contain
            // any reference so therefore it's likely that the object hasn't been built yet; try building it now.
            object = [self buildNamedObject:name];
        }
    }
    return object;
}

- (void)configureWithData:(id)configData {
    IFConfiguration *configuration = [[IFConfiguration alloc] initWithData:configData];
    [self configureWith:configuration];
}

- (void)doStandardProtocolChecks:(id)object {
    // If the new instance is container aware then pass reference to this container.
    if ([object conformsToProtocol:@protocol(IFIOCContainerAware)]) {
        ((id<IFIOCContainerAware>)object).iocContainer = self;
    }
    // If instance is a service then add to list of services.
    if ([object conformsToProtocol:@protocol(IFService)]) {
        [_services addObject:(id<IFService>)object];
    }
}

#pragma mark - Private methods

- (BOOL)hasInstantiationHint:(IFConfiguration *)configuration {
    return [configuration hasValue:@"*type"] || [configuration hasValue:@"*ios-class"] || [configuration hasValue:@"*factory"];
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
    _running = YES;
    for (id<IFService> service in _services) {
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
    for (id<IFService> service in _services) {
        @try {
            if ([service respondsToSelector:stopService]) {
                [service stopService];
            }
        }
        @catch (NSException *exception) {
            DDLogCError(@"Error stopping service %@: %@", [service class], exception);
        }
    }
    _running = NO;
}

#pragma mark - IFConfigurationRoot

- (id)getValue:(NSString *)name asRepresentation:(NSString *)representation {
    id value = [self getNamed:name];
    if (value && ![@"bare" isEqualToString:representation]) {
        value = [IFTypeConversions value:value asRepresentation:representation];
    }
    return value;
}

#pragma mark - IFMessageTargetContainer

- (BOOL)dispatchMessage:(IFMessage *)message sender:(id)sender {
    BOOL dispatched = NO;
    if ([message hasEmptyTarget]) {
        // Message is targetted at this object.
        dispatched = [self handleMessage:message sender:sender];
    }
    else {
        // Look-up the message target in named objects.
        NSString *targetHead = [message targetHead];
        id target = [_named objectForKey:targetHead];
        if (target) {
            message = [message popTargetHead];
            // If we have the intended target, and the target is a message handler, then let it handle the message.
            if ([message hasEmptyTarget]) {
                if ([target conformsToProtocol:@protocol(IFMessageHandler)]) {
                    dispatched = [(id<IFMessageHandler>)target handleMessage:message sender:sender];
                }
            }
            else if ([target conformsToProtocol:@protocol(IFMessageTargetContainer)]) {
                // Let the current target dispatch the message to its intended target.
                dispatched = [(id<IFMessageTargetContainer>)target dispatchMessage:message sender:sender];
            }
        }
    }
    return dispatched;
}

#pragma mark - IFMessageHandler

- (BOOL)handleMessage:(IFMessage *)message sender:(id)sender {
    return NO;
}

@end
