//
//  IFStringSchemeHandler.m
//  EventPacComponents
//
//  Created by Julian Goacher on 13/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFStringSchemeHandler.h"

// Scheme handler for resolving strings. The string always corresponds to the URI's
// scheme specific part.
@implementation IFStringSchemeHandler

- (IFResource *)handle:(IFCompoundURI *)uri parameters:(NSDictionary*)params parent:(IFResource *)parent {
    return [[IFResource alloc] initWithData:uri.name uri:uri parent:parent];
}

@end
