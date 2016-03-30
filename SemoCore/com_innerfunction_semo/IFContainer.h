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

#import <Foundation/Foundation.h>
#import "IFConfiguration.h"
#import "IFMessageRouter.h"
#import "IFMessageReceiver.h"
#import "IFService.h"
#import "IFTypeInfo.h"

/**
 * A container for named objects and services.
 * Acts as an object factory and IOC container. Objects built using this class are
 * instantiated and configured using an object definition read from a JSON configuration.
 * The object's properties may be configured using other built objects, or using references
 * to named objects contained by the container.
 */
@interface IFContainer : NSObject <IFConfigurationData, IFService, IFMessageReceiver, IFMessageRouter> {
    /// A map of named objects.
    NSMutableDictionary *_named;
    /// A list of contained services.
    NSMutableArray *_services;
    /// Map of standard type names onto platform specific class names.
    IFConfiguration *_types;
    /// The container's configuration.
    IFConfiguration *_containerConfig;
    /// Type info for the container's properties - allows type inferring of named properties.
    IFTypeInfo *_propertyTypeInfo;
    /**
     * A map of pending object names (i.e. objects in the process of being configured) mapped onto
     * a list of pending value references (i.e. property value references to other pending objects,
     * which are caused by circular dependency cycles and which can't be fully resolved until the
     * referenced value has been fully built).
     * Used to detect dependency cycles when building the named object graph.
     * @see <IFPendingNamed>
     */
    NSMutableDictionary *_pendingNames;
    /**
     * A map of pending property value reference counts, keyed by the property's parent object. Used to
     * manage deferred calls to the <IFIOCContainerAware> [afterIOCConfiguration:] method.
     */
    NSMutableDictionary *_pendingValueRefCounts;
    /**
     * A map of pending value object configurations. These are the configurations for the parent
     * objects of pending property values. These are needed for deferred calls to the
     * <IFIOCContainerAware> [afterIOCConfiguration] method.
     */
    NSMutableDictionary *_pendingValueObjectConfigs;
    /// Flag indicating whether the container and all its services are running.
    BOOL _running;
}

/** Get a named component. */
- (id)getNamed:(NSString *)name;
/** Set the type map. */
- (void)setTypes:(IFConfiguration *)types;
/** Add additional type name mappings to the type map. */
- (void)addTypes:(id)types;
/**
 * Instantiate and configure an object using the specified configuration.
 * @param configuration A configuration describing the object to build.
 * @param identifier    An identifier (e.g. the configuration's key path) used identify the object in logs.
 * @return The instantiated and fully configured object.
 */
- (id)buildObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
/**
 * Instantiate an object from the specified configuration.
 * @param configuration A configuration with instantiation hints that can be used to create an object instance.
 * @param identifier    An identifier (e.g. the configuration's key path) used identify the object in logs.
 * @return A newly instantiated object.
 */
- (id)instantiateObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
/**
 * Instantiate an instance of the named type. Looks for a classname in the set of registered types, and then
 * returns the result of calling [newInstanceForClassName: withConfiguration:].
 */
- (id)newInstanceForTypeName:(NSString *)typeName withConfiguration:(IFConfiguration *)configuration;
/**
 * Instantiate an instance of the named class.
 * @return Returns a new instance of the class, unless a configuration proxy is registered for the class name
 * in which case a new instance of the proxy class is returned.
 */
- (id)newInstanceForClassName:(NSString *)className withConfiguration:(IFConfiguration *)configuration;
/**
 * Configure an object using the specified configuration.
 * @param object        The object to configure.
 * @param configuration The object's configuration.
 * @param identifier    An identifier (e.g. the configuration's key path) used identify the object in logs.
 */
- (void)configureObject:(id)object withConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
/**
 * Configure the container and its contents using the specified configuration.
 * The set of 'named' components is instantiated from the top-level configuration properties. In addition, if
 * any named property has the same name as one of the container's properties, then the container property is set
 * to the value of the named property. Type inference will be attempted for named container properties without
 * explicitly configured types. The mapping of named container properties is primarily useful in container subclasses,
 * and can be used to define functional modules as configurable containers.
 */
- (void)configureWith:(IFConfiguration *)configuration;
/** Configure the container with the specified data. */
- (void)configureWithData:(id)configData;
/** Perform standard container-recognized protocol checks on a new object instance. */
- (void)doStandardProtocolChecks:(id)object;

/**
 * Register an IOC configuration proxy class for properties of a specific class.
 * The proxy will be used for all subclasses of the property class also, unless a different proxy is registered
 * for a specific subclass. No proxy will be used for a specific subclass if a nil proxy class name is registered.
 */
+ (void)registerConfigurationProxyClassName:(__unsafe_unretained Class)proxyClass forClassName:(NSString *)className;

@end
