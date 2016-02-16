//
//  IFIOCObjectFactoryBase.m
//  SemoCore
//
//  Created by Julian Goacher on 16/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFIOCObjectFactoryBase.h"

@implementation IFIOCObjectFactoryBase

- (id)initWithBaseConfiguration:(NSDictionary *)baseConfiguration {
    self = [super init];
    if (self) {
        IFConfiguration *configuration = [[IFConfiguration alloc] initWithData:baseConfiguration];
        _baseConfiguration = [configuration flatten];
    }
    return self;
}

- (id)buildObjectWithConfiguration:(IFConfiguration *)configuration
                       inContainer:(IFContainer *)container
                    withParameters:(NSDictionary *)params
                        identifier:(NSString *)identifier {
    // Flatten the object configuration.
    configuration = [configuration flatten];
    // Extend the object configuration from the base configuration.
    configuration = [_baseConfiguration mergeConfiguration:configuration];
    // If any parameters then extend the configuration using them.
    if (params) {
        configuration = [configuration extendWithParameters:params];
    }
    // Ask the container to build the object, then return the result.
    return [container buildObjectWithConfiguration:configuration identifier:identifier];
}

- (id)buildObjectWithConfiguration:(IFConfiguration *)configuration
                       inContainer:(IFContainer *)container
                        identifier:(NSString *)identifier {
    return [self buildObjectWithConfiguration:configuration inContainer:container withParameters:nil identifier:identifier];
}

@end
