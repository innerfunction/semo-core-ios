//
//  IFMakeScheme.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFMakeScheme.h"

@implementation IFMakeScheme

- (id)initWithContainer:(IFContainer *)_container {
    self = [super init];
    if (self) {
        container = _container;
    }
    return self;
}

- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference {
    return uri;
}

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params parent:(id<IFResourceContext>)parent {
    id result = nil;
    id _config = [container getNamed:uri.name];
    if (_config && [_config isKindOfClass:[IFConfiguration class]]) {
        IFConfiguration *config = (IFConfiguration *)_config;
        config = [config extendWithParameters:params];
        result = [container buildObjectWithConfiguration:config identifier:[uri description]];
    }
    return result;
}

@end
