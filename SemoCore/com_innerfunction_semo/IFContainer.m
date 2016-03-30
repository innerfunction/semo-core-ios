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
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFContainer.h"
#import "IFConfigurable.h"
#import "IFIOCConfigurable.h"
#import "IFIOCTypeInspectable.h"
#import "IFIOCConfigurationInitable.h"
#import "IFIOCContainerAware.h"
#import "IFIOCObjectAware.h"
#import "IFIOCObjectFactory.h"
#import "IFIOCProxy.h"
#import "IFIOCProxyObject.h"
#import "IFPendingNamed.h"
#import "IFPostScheme.h"
#import "IFTypeConversions.h"
#import "IFLogging.h"

/** Entry for a configurable proxy in the proxy lookup table. */
@interface IFIOCProxyLookupEntry : NSObject {
    __unsafe_unretained Class _class;
}

- (id)initWithClass:(__unsafe_unretained Class)class;

/** Use the entry to instantiate a new proxy instance with no in-place value. */
- (id<IFIOCProxy>)instantiateProxy;

/** Use the entry to instantiate a new proxy instance with an in-place value. */
- (id<IFIOCProxy>)instantiateProxyWithValue:(id)value;

@end

@interface IFContainer ()

/** Test if a configuration contains an instantiation hint, e.g. a type, class or factory specifier. */
- (BOOL)hasInstantiationHint:(IFConfiguration *)configuration;

/** Configure a named property of an object using the specified configuration and type info. */
- (id)configureProperty:(NSString *)propName
                   info:(IFPropertyInfo *)propInfo
                 object:(id)object
          configuration:(IFConfiguration *)configuration;

/** Resolve an object property value compatible with the specified type from the specified configuration. */
- (id)resolveObjectPropertyOfType:(__unsafe_unretained Class)type
                fromConfiguration:(IFConfiguration *)configuration
                             name:(NSString *)name
                            value:(id)value;

/** Instantiate and configure a named object. */
- (id)buildNamedObject:(NSString *)name;

/** Set a named property on an object. */
- (id)setProperty:(id)propKey info:(IFPropertyInfo *)propInfo object:(id)object value:(id)value;

/** Increment the number of pending value refs for an object. */
- (void)incPendingValueRefCountForPendingObject:(IFPendingNamed *)pending;

/** Lookup a configuration proxy for an object instance. */
+ (IFIOCProxyLookupEntry *)lookupConfigurationProxyForObject:(id)object;

/** Lookup a configuration proxy for a named class. */
+ (IFIOCProxyLookupEntry *)lookupConfigurationProxyForClassName:(NSString *)className;

/** Lookup a configuration proxy for a class. */
+ (IFIOCProxyLookupEntry *)lookupConfigurationProxyForClass:(__unsafe_unretained Class)class className:(NSString *)className;

@end

@implementation IFContainer

- (id)init {
    self = [super init];
    if (self) {
        _named = [NSMutableDictionary new];
        _services = [NSMutableArray new];
        _types = [IFConfiguration emptyConfiguration];
        _running = NO;
        _propertyTypeInfo = [IFTypeInfo typeInfoForObject:self];
        _pendingNames = [NSMutableDictionary new];
        _pendingValueRefCounts = [NSMutableDictionary new];
        _pendingValueObjectConfigs = [NSMutableDictionary new];
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
        _types = [_types mixinConfiguration:typeConfig];
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
                DDLogError(@"%@: Instantiating %@, no class name found for type %@", LogTag, identifier, type);
            }
        }
        else {
            DDLogError(@"%@: Instantiating %@, Component configuration missing *type or *ios-class property", LogTag, identifier);
        }
    }
    if (className) {
        object = [self newInstanceForClassName:className withConfiguration:configuration];
    }
    return object;
}

- (id)newInstanceForClassName:(NSString *)className withConfiguration:(IFConfiguration *)configuration {
    // If config proxy available for classname then instantiate proxy instead of new instance.
    IFIOCProxyLookupEntry *proxyEntry = [IFContainer lookupConfigurationProxyForClassName:className];
    if (proxyEntry) {
        return [proxyEntry instantiateProxy];
    }
    // Otherwise continue with class instantiation.
    Class class = NSClassFromString(className);
    if (class == nil) {
        DDLogError(@"%@: Class not found %@", LogTag, className);
        return nil;
    }
    id instance = [class alloc];
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
        NSArray *valueNames = [configuration getValueNames];
        for (NSString *name in valueNames) {
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
                else {
                    continue; // Skip all other reserved names
                }

            }
            IFPropertyInfo *propertyInfo = [typeInfo infoForProperty:propName];
            if (!propertyInfo) {
                continue;
            }
            [self configureProperty:propName info:propertyInfo object:object configuration:configuration];
        }
        if ([object conformsToProtocol:@protocol(IFIOCConfigurable)]) {
            NSValue *objectKey = [NSValue valueWithNonretainedObject:object];
            // Check that no pending value refs are outstanding for the object.
            if (_pendingValueRefCounts[objectKey] == nil) {
                [(id<IFIOCConfigurable>)object afterConfiguration:configuration inContainer:self];
            }
            else {
                // Else afterConfiguration: is called once all pending values are resolved; record the object
                // configuration for use later.
                _pendingValueObjectConfigs[objectKey] = configuration;
            }
        }
    }
    // If running and the object is a service instance then start the service now that it is fully configured.
    if (_running && [object conformsToProtocol:@protocol(IFService)]) {
        [(id<IFService>)object startService];
    }
}

- (id)configureProperty:(NSString *)propName info:(IFPropertyInfo *)propInfo object:(id)object configuration:(IFConfiguration *)configuration {
    id<IFIOCTypeInspectable> typeInspectable = nil;
    if ([object conformsToProtocol:@protocol(IFIOCTypeInspectable)]) {
        typeInspectable = (id<IFIOCTypeInspectable>)object;
    }
    id value = nil;
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
    else if ([propInfo isId]) {
        value = [configuration getValue:propName];
    }
    else if ([propInfo isAssignableFrom:[NSNumber class]]) {
        value = [configuration getValueAsNumber:propName];
    }
    else if ([propInfo isAssignableFrom:[NSString class]]) {
        value = [configuration getValueAsString:propName];
    }
    else if ([propInfo isAssignableFrom:[NSDate class]]) {
        value = [configuration getValueAsDate:propName];
    }
    else if ([propInfo isAssignableFrom:[UIImage class]]) {
        value = [configuration getValueAsImage:propName];
    }
    else if ([propInfo isAssignableFrom:[UIColor class]]) {
        value = [configuration getValueAsColor:propName];
    }
    else if ([propInfo isAssignableFrom:[IFConfiguration class]]) {
        value = [configuration getValueAsConfiguration:propName];
    }
    else if ([propInfo isAssignableFrom:[NSArray class]]) {
        if ([configuration getValueType:propName] == IFValueTypeList) {
            NSArray *list = (NSArray *)[configuration getValue:propName asRepresentation:@"json"];
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
                if ([propValue isKindOfClass:[IFPendingNamed class]]) {
                    // Value is a pending named value. Record the current property and object info, but skip further processing.
                    // The property value will be set once the named reference is fully configured, see buildNamedObject:.
                    IFPendingNamed *pending = (IFPendingNamed *)propValue;
                    pending.key = [NSNumber numberWithInteger:idx];
                    pending.object = propValues;
                    // Keep count of the number of pending value refs for the current object.
                    [self incPendingValueRefCountForPendingObject:pending];
                }
                else {
                    [propValues addObject:propValue];
                }
            }
            value = propValues;
        }
    }
    else if ([propInfo isAssignableFrom:[NSDictionary class]]) {
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
                    if ([propValue isKindOfClass:[IFPendingNamed class]]) {
                        // Value is a pending named value. Record the current property and object info, but skip further processing.
                        // The property value will be set once the named reference is fully configured, see buildNamedObject:.
                        IFPendingNamed *pending = (IFPendingNamed *)propValue;
                        pending.key = valueName;
                        pending.object = propValues;
                        // Keep count of the number of pending value refs for the current object.
                        [self incPendingValueRefCountForPendingObject:pending];
                    }
                    else {
                        [propValues setObject:propValue forKey:valueName];
                    }
                }
            }
            value = propValues;
        }
    }
    else {
        __unsafe_unretained Class propClass = [propInfo getPropertyClass];
        id propValue = [object valueForKey:propName];
        value = [self resolveObjectPropertyOfType:propClass fromConfiguration:configuration name:propName value:propValue];
    }
    value = [self setProperty:propName info:propInfo object:object value:value];
    return value;
}

- (id)setProperty:(id)propKey info:(IFPropertyInfo *)propInfo object:(id)object value:(id)value {
    NSString *propName = [propKey description];
    // Notify object aware values that they are about to be injected into the object under the current property name.
    // NOTE: This happens at this point - instead of after the value injection - so that value proxies can receive the
    // notification. If it notification was deferred until after the injection then any proxied values probably won't
    // implement the protocol.
    if ([value conformsToProtocol:@protocol(IFIOCObjectAware)]) {
        [(id<IFIOCObjectAware>)value notifyIOCObject:object propertyName:propName];
    }
    // If value is a config proxy then unwrap the underlying value
    if ([value conformsToProtocol:@protocol(IFIOCProxy)]) {
        value = [(id<IFIOCProxy>)value unwrapValue];
    }
    if ([value isKindOfClass:[IFPendingNamed class]]) {
        // Value is a pending named value. Record the current property and object info, but skip further processing.
        // The property value will be set once the named reference is fully configured, see buildNamedObject:.
        IFPendingNamed *pending = (IFPendingNamed *)value;
        pending.key = propKey;
        pending.propInfo = propInfo;
        pending.object = object;
        // Keep count of the number of pending value refs for the current object.
        [self incPendingValueRefCountForPendingObject:pending];
    }
    else if (value != nil) {
        if ([propInfo isWriteable]) {
            // Standard object property reference.
            [object setValue:value forKey:propName];
        }
        else if ([object isKindOfClass:[NSDictionary class]]) {
            // Dictionary collection entry.
            // NOTE: Assuming here that object is a mutable dictionary.
            object[propName] = value;
        }
        else if ([object isKindOfClass:[NSArray class]]) {
            // Array item.
            // NOTE: Assuming here that object is a mutable array, and that propKey is the
            // index of the value's position in the array.
            [(NSMutableArray *)object insertObject:value atIndex:[(NSNumber *)propKey integerValue]];
        }
    }
    return value;
}

// Configure the container with the specified configuration.
// The container performs implicit dependency ordering. This means that if an object A has a dependency
// on another object B, then B will be built (instantiated & configured) before A. This will work for an
// arbitrary length dependency chain (e.g. A -> B -> C -> etc.)
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
// * The container maintains a map of names being built. This allows the container to detect dependency
//   cycles and so avoid infinite regression. Dependency cycles are resolved, but the final object in a
//   cycle won't be fully configured when injected into the dependent.
- (void)configureWith:(IFConfiguration *)configuration {
    _containerConfig = configuration;
    // Iterate over named object configs and build each object.
    NSArray *names = [_containerConfig getValueNames];
    for (NSString *name in names) {
        // Build the object only if it has not already been built and added to _named_.
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
    [_pendingNames setObject:@[] forKey:name];
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
        // If the named object corresponds to a property on the container then try setting that property.
        if (propertyInfo) {
            // TODO: Is the 'if' term needed here, or can just the 'else' term be used?
            // If the 'if' term is needed then need to add code to check for IFIOCObjectAware and IFIOCProxy
            // (see lines ~306-312 above); otherwise configureProperty: will do the required checks.
            if ([propertyInfo isAssignableFrom:[object class]]) {
                [self setValue:object forKey:name];
            }
            // TODO: Following doesn't make total sense, as a property value (object) has already been resolved at
            // this point, yet the value is discarded and re-resolved below. Note that currently only top-level
            // string property values seem to take this route. Any change here relates to the TODO above on proxies.
            else {
                // Else try setting through the standard property setting machinery.
                object = [self configureProperty:name info:propertyInfo object:self configuration:_containerConfig];
            }
        }
        [_named setObject:object forKey:name];
    }
    // Object is configured, notify any pending named references
    NSArray *pendings = [_pendingNames objectForKey:name];
    for (IFPendingNamed *pending in pendings) {
        id value = [pending resolveValue:object];
        [self setProperty:pending.key info:pending.propInfo object:pending.object value:value];
        // Decrement the number of pending value refs for the property object.
        NSInteger refCount = [(NSNumber *)_pendingValueRefCounts[pending.objectKey] integerValue] - 1;
        if (refCount > 0) {
            _pendingValueRefCounts[pending.objectKey] = [NSNumber numberWithInteger:refCount];
        }
        else {
            [_pendingValueRefCounts removeObjectForKey:pending.objectKey];
            // The property object is now fully configured, invoke its afterConfiguration: method if it
            // implements IFIOCConfigurable
            // TODO: Remove configuration from IOCConfigurable calls, _pendingValueObjectConfigs not needed then.
            if ([pending.object conformsToProtocol:@protocol(IFIOCConfigurable)]) {
                IFConfiguration *objConfig = _pendingValueObjectConfigs[pending.objectKey];
                [(id<IFIOCConfigurable>)pending.object afterConfiguration:objConfig inContainer:self];
                [_pendingValueObjectConfigs removeObjectForKey:pending.objectKey];
            }
        }
    }
    // Finished building the current name, remove from list.
    [_pendingNames removeObjectForKey:name];
    return object;
}

// Get a named object. Will attempt building the object if necessary.
- (id)getNamed:(NSString *)name {
    id object = [_named objectForKey:name];
    // If named object not found then consider whether to try building it.
    if (object == nil) {
        // Check for a dependency cycle. If the requested name exists in _pendingNames_ then the named object is currently
        // being configured.
        NSArray *pending = _pendingNames[name];
        if (pending != nil) {
            //NSLog(@"WARNING: Named dependency cycle detected %@ -> %@", [_pendingNames componentsJoinedByString:@" -> "], name);
            NSLog(@"IDO: Named dependency cycle detected, creating pending entry for %@...", name);
            // Create a placeholder object and record in the list of placeholders waiting for the named configuration to complete.
            // Note that the placeholder is returned in place of the named - code above detects the placeholder and ensures that
            // the correct value is resolved instead.
            object = [IFPendingNamed new];
            pending = [pending arrayByAddingObject:object];
            [_pendingNames setObject:pending forKey:name];
        }
        else if ([_containerConfig hasValue:name]) {
            //NSLog(@"IDO: Prioritizing building of named %@ -> %@", [_pendingNames componentsJoinedByString:@"."], name);
            // The container config contains a configuration for the wanted name, but _named_ doesn't contain
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
    return [configuration hasValue:@"*type"]
    || [configuration hasValue:@"*ios-class"]
    || [configuration hasValue:@"*factory"];
}

- (id)resolveObjectPropertyOfType:(__unsafe_unretained Class)propClass
                fromConfiguration:(IFConfiguration *)configuration
                             name:(NSString *)name
                            value:(id)value {
    id object = [configuration getValue:name];
    // Return pending names immediately.
    if ([object isKindOfClass:[IFPendingNamed class]]) {
        return object;
    }
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
            // If [value class] has a config proxy then instantiate that using the value.
            IFIOCProxyLookupEntry *proxyEntry = [IFContainer lookupConfigurationProxyForObject:value];
            if (proxyEntry) {
                value = [proxyEntry instantiateProxyWithValue:value];
            }
            [self configureObject:value withConfiguration:propConfig identifier:name];
            // Return the configured value.
            return value;
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
        // Try setting property again.
        if ([[object class] isSubclassOfClass:propClass]) {
            return object;
        }
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
    // If class is nil then then property is defined with (id) type, so should accept the current object, if any.
    if (propClass == nil) {
        return object;
    }
    // Unable to instantiate an object of a compatible type, so return nil.
    return nil;
}

- (void)incPendingValueRefCountForPendingObject:(IFPendingNamed *)pending {
    NSNumber *refCount = _pendingValueRefCounts[pending.objectKey];
    if (refCount) {
        _pendingValueRefCounts[pending.objectKey] = [NSNumber numberWithInteger:([refCount integerValue] + 1)];
    }
    else {
        _pendingValueRefCounts[pending.objectKey] = @1;
    }
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

#pragma mark - IFConfigurationData

- (id)getValue:(NSString *)keyPath asRepresentation:(NSString *)representation {
    id value = [self getNamed:keyPath];
    if (value && ![@"bare" isEqualToString:representation]) {
        value = [IFTypeConversions value:value asRepresentation:representation];
    }
    return value;
}

#pragma mark - IFMessageRouter

- (BOOL)routeMessage:(IFMessage *)message sender:(id)sender {
    BOOL routed = NO;
    if ([message hasEmptyTarget]) {
        // Message is targeted at this object.
        routed = [self receiveMessage:message sender:sender];
    }
    else {
        // Look-up the message target in named objects.
        NSString *targetHead = [message targetHead];
        id target = [_named objectForKey:targetHead];
        if (target) {
            message = [message popTargetHead];
            // If we have the intended target, and the target is a message handler, then let it handle the message.
            if ([message hasEmptyTarget]) {
                if ([target conformsToProtocol:@protocol(IFMessageReceiver)]) {
                    routed = [(id<IFMessageReceiver>)target receiveMessage:message sender:sender];
                }
            }
            else if ([target conformsToProtocol:@protocol(IFMessageRouter)]) {
                // Let the current target dispatch the message to its intended target.
                routed = [(id<IFMessageRouter>)target routeMessage:message sender:sender];
            }
        }
    }
    return routed;
}

#pragma mark - IFMessageReceiver

- (BOOL)receiveMessage:(IFMessage *)message sender:(id)sender {
    return NO;
}

#pragma mark - Static methods

// May of configuration proxies keyed by class name. Classes without a registered proxy get an NSNull entry.
static NSMutableDictionary *IFContainer_proxies;

+ (void)initialize {
    IFContainer_proxies = [NSMutableDictionary new];
    NSDictionary *registeredProxyClasses = [IFIOCProxyObject registeredProxyClasses];
    for (NSString *className in registeredProxyClasses) {
        NSValue *value = (NSValue *)registeredProxyClasses[className];
        __unsafe_unretained Class proxyClass = (Class)[value nonretainedObjectValue];
        IFIOCProxyLookupEntry *proxyEntry = [[IFIOCProxyLookupEntry alloc] initWithClass:proxyClass];
        IFContainer_proxies[className] = proxyEntry;
    }
}

+ (void)registerConfigurationProxyClassName:(__unsafe_unretained Class)proxyClass forClassName:(NSString *)className {
    if (!proxyClass) {
        IFContainer_proxies[className] = [NSNull null];
    }
    else {
        IFIOCProxyLookupEntry *proxyEntry = [[IFIOCProxyLookupEntry alloc] initWithClass:proxyClass];
        IFContainer_proxies[className] = proxyEntry;
    }
}

+ (IFIOCProxyLookupEntry *)lookupConfigurationProxyForObject:(id)object {
    __unsafe_unretained Class class = [object class];
    NSString *className = NSStringFromClass(class);
    return [IFContainer lookupConfigurationProxyForClass:class className:className];
}

+ (IFIOCProxyLookupEntry *)lookupConfigurationProxyForClassName:(NSString *)className {
    __unsafe_unretained Class class = NSClassFromString(className);
    return [IFContainer lookupConfigurationProxyForClass:class className:className];
}

+ (IFIOCProxyLookupEntry *)lookupConfigurationProxyForClass:(__unsafe_unretained Class)class className:(NSString *)className {
    // First check for an entry under the current object's specific class name.
    id proxyEntry = IFContainer_proxies[className];
    if (proxyEntry != nil) {
        // NSNull at this stage indicates no proxy available for the specific object class.
        return proxyEntry == [NSNull null] ? nil : (IFIOCProxyLookupEntry *)proxyEntry;
    }
    // No entry found for the specific class, search for the closest superclass proxy.
    NSString *specificClassName = className;
    class = [class superclass];
    while (class) {
        className = NSStringFromClass(class);
        proxyEntry = IFContainer_proxies[className];
        if (proxyEntry) {
            // Proxy found, record the same proxy for the specific class and return the result.
            IFContainer_proxies[specificClassName] = proxyEntry;
            return proxyEntry == [NSNull null] ? nil : (IFIOCProxyLookupEntry *)proxyEntry;
        }
        // Nothing found yet, continue to the next superclass.
        class = [class superclass];
    }
    // If we get to here then there is no registered proxy available for the object's class or any of its
    // superclasses; register an NSNull in the dictionary so that future lookups can complete quicker.
    IFContainer_proxies[specificClassName] = [NSNull null];
    return nil;
}

@end

#pragma mark - IFIOCProxyLookupEntry

@implementation IFIOCProxyLookupEntry

- (id)initWithClass:(__unsafe_unretained Class)class {
    self = [super init];
    if (self) {
        _class = class;
    }
    return self;
}

- (id<IFIOCProxy>)instantiateProxy {
    return (id<IFIOCProxy>)[_class new];
}

- (id<IFIOCProxy>)instantiateProxyWithValue:(id)value {
    id<IFIOCProxy> instance = (id<IFIOCProxy>)[_class alloc];
    return [instance initWithValue:value];
}

@end
