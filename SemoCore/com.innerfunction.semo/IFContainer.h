//
//  IFContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFConfiguration.h"
#import "IFService.h"

/**
 * A container for named objects and services.
 * Acts as an object factory and IOC container. Objects built using this class are
 * instantiated and configured using an object definition read from a JSON configuration.
 * The object's properties may be configured using other built objects, or using references
 * to named objects contained by the container.
 */
@interface IFContainer : NSObject <IFService> {
    // A map of named objects.
    NSMutableDictionary *named;
    // A list of contained services.
    NSMutableArray *services;
    // Map of type names onto class names.
    IFConfiguration *types;
    // Flag indicating whether the container and all its services are running.
    BOOL running;
}

/** Get a named component. */
- (id)getNamed:(NSString *)name;
/** Set the type map. */
- (void)setTypes:(IFConfiguration *)types;
/** Instantiate and configure an object using the specified configuration. */
- (id)buildObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
/** Instantiate an object from the specified configuration. */
- (id)instantiateObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
/** Instantiate an instance of the named class. */
- (id)newInstanceForClassName:(NSString *)className;
/** Configure an object using the specified configuration. */
- (void)configureObject:(id)object withConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
/** Configure the container and its contents using the specified configuration. */
- (void)configureWith:(IFConfiguration *)configuration;

@end
