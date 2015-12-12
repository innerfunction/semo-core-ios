//
//  IFNamedScheme.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFNamedScheme.h"

@implementation IFNamedSchemeHandler

- (id)initWithNamed:(NSDictionary *)_named {
    self = [super init];
    if (self) {
        named = _named;
    }
    return self;
}

- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference {
    return uri;
}

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params parent:(id<IFResourceContext>)parent {
    id namedObj = [named objectForKey:uri.name];
    return namedObj;
}

@end