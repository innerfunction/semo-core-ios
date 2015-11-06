//
//  IFURIResolver.h
//  EventPacComponents
//
//  Created by Julian Goacher on 12/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFCompoundURI.h"
#import "IFURIHandling.h"

@interface IFStandardURIHandler : NSObject <IFURIHandler> {
    NSMutableDictionary *schemeHandlers;
    id<IFResourceContext> resourceContext;
}

- (id)initWithResourceContext:(id<IFResourceContext>)context;
- (id)initWithMainBundlePath:(NSString *)mainBundlePath resourceContext:(id<IFResourceContext>)context;
/** Test if the resolver has a registered handler for the named scheme. */
- (BOOL)hasHandlerForURIScheme:(NSString *)scheme;
/** Add a scheme handler. */
- (void)addHandler:(id<IFSchemeHandler>)handler forScheme:(NSString *)scheme;
/** Return a list of all registered scheme names. */
- (NSArray *)getURISchemeNames;
/** The the handler for a named scheme. */
- (id<IFSchemeHandler>)getHandlerForURIScheme:(NSString *)scheme;

@end
