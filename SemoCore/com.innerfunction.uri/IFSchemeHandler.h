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

// Protocol implemented by classes which resolve internal URIs belonging to a particular
// internal URI scheme.
@protocol IFSchemeHandler <NSObject>

// Handle a URI with the specified parameters.
// Parameters values (which are also URIs) will have been resolved before being passed to this method.
- (IFResource *)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params parent:(IFResource *)parent;

@optional

// Resolve a URI against a reference URI. Used by schemes which support relative URIs, to resolve then to absolute URIs.
- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference;

@end
