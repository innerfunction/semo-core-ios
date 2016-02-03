//
//  IFURISchemeHandler.h
//  EventPacComponents
//
//  Created by Julian Goacher on 13/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFCompoundURI.h"

@protocol IFSchemeHandler;

/** A protocol for handling URIs by dereferencing them to resources or values. */
@protocol IFURIHandler <NSObject>

/**
 * Dereference a URI to a resource.
 */
- (id)dereference:(id)uri;
/**
 * Return a new URI handler with a modified context (used to dereference relative URIs).
 */
- (id<IFURIHandler>)modifyContext:(IFCompoundURI *)uri;
/**
 * Test if the resolver has a registered handler for the named scheme.
 */
- (BOOL)hasHandlerForURIScheme:(NSString *)scheme;
/**
 * Add a scheme handler.
 */
- (void)addHandler:(id<IFSchemeHandler>)handler forScheme:(NSString *)scheme;
/**
 * Return a list of all registered scheme names.
 */
- (NSArray *)getURISchemeNames;
/**
 * The the handler for a named scheme.
 */
- (id<IFSchemeHandler>)getHandlerForURIScheme:(NSString *)scheme;

@end

/** A protocol for handling URIs in a specific internal URI scheme. */
@protocol IFSchemeHandler <NSObject>

/**
 * Dereference a URI.
 * Is passed a set of URI parameters as already dereferenced values.
 */
- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params;

@optional

/** Resolve a possibly relative URI against a reference URI. */
- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference;

@end
