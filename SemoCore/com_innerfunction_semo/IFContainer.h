//
//  IFContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFConfiguration.h"
#import "IFPostActionHandler.h"
#import "IFPostActionTargetContainer.h"
#import "IFService.h"
#import "IFTypeInfo.h"

/**
 * A container for named objects and services.
 * Acts as an object factory and IOC container. Objects built using this class are
 * instantiated and configured using an object definition read from a JSON configuration.
 * The object's properties may be configured using other built objects, or using references
 * to named objects contained by the container.
 */
@interface IFContainer : NSObject <IFService, IFConfigurationRoot, IFPostActionHandler, IFPostActionTargetContainer> {
    // A map of named objects.
    NSMutableDictionary *_named;
    // A list of contained services.
    NSMutableArray *_services;
    // Map of type names onto class names.
    IFConfiguration *_types;
    // The container's configuration.
    IFConfiguration *_containerConfig;
    // Type info for the container's properties - allows type inferring of named properties.
    IFTypeInfo *_propertyTypeInfo;
    // A list containing the names of objects currently being built (instantiated/configured).
    // Used to detect dependency cycles when building the named object graph.
    NSMutableArray *_pendingNames;
    // Flag indicating whether the container and all its services are running.
    BOOL _running;
}

/** Get a named component. */
- (id)getNamed:(NSString *)name;
/** Set the type map. */
- (void)setTypes:(IFConfiguration *)types;
/** Add additional type name mappings to the type map. */
- (void)addTypes:(id)types;
/** Instantiate and configure an object using the specified configuration. */
- (id)buildObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
/** Instantiate an object from the specified configuration. */
- (id)instantiateObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
/** Instantiate an instance of the named class. */
- (id)newInstanceForClassName:(NSString *)className withConfiguration:(IFConfiguration *)configuration;
/** Instantiate an instance of the named type. */
- (id)newInstanceForTypeName:(NSString *)typeName withConfiguration:(IFConfiguration *)configuration;
/** Configure an object using the specified configuration. */
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
/** Post an action URI. */
- (void)postAction:(NSString *)actionURI sender:(id)sender;

@end
