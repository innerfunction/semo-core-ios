//
//  IFURISchemeHandler.h
//  EventPacComponents
//
//  Created by Julian Goacher on 13/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFCompoundURI.h"

@class IFResource;
@protocol IFResourceContext;
@protocol IFSchemeHandler;

/** A protocol for handling URIs by dereferencing them to resources or values. */
@protocol IFURIHandler <NSObject>

/**
 * Dereference a URI to a resource.
 */
- (IFResource *)dereference:(id)uri;
/**
 * Dereference a URI to a resource.
 */
- (IFResource *)dereference:(id)uri context:(id<IFResourceContext>)context;
/**
 * Dereference a URI to its bare value. May or may not return a resource, depending on the scheme.
 */
- (id)dereferenceToValue:(id)uri;
/**
 * Dereference a URI to its bare value. May or may not return a resource, depending on the scheme.
 */
- (id)dereferenceToValue:(id)uri context:(id<IFResourceContext>)context;
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
- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params parent:(id<IFResourceContext>)parent;

@optional

/** Resolve a possibly relative URI against a reference URI. */
- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference;

@end

/** A protocol for providing context to URI resources. */
@protocol IFResourceContext <NSObject>

/**
 * A dictionary of in-scope URIs, keyed by scheme.
 * Used to resolve relative URIs to absolute.
 */
@property (nonatomic, strong) NSDictionary *uriSchemeContext;
/**
 * The in-scope URI handler.
 */
@property (nonatomic, strong) id<IFURIHandler> uriHandler;

@end
