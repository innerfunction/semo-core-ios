//
//  IFIOCObjectFactoryBase.h
//  SemoCore
//
//  Created by Julian Goacher on 16/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFConfiguration.h"
#import "IFContainer.h"
#import "IFIOCObjectFactory.h"

/**
 * Base class for IOC object factory instances.
 */
@interface IFIOCObjectFactoryBase : NSObject <IFIOCObjectFactory> {
    // A default base configuration for instances produced by this class.
    // Typically minimal implementation should contain a *type or *ios-class property.
    IFConfiguration *_baseConfiguration;
}

- (id)initWithBaseConfiguration:(NSDictionary *)baseConfiguration;
- (id)buildObjectWithConfiguration:(IFConfiguration *)configuration
                       inContainer:(IFContainer *)container
                    withParameters:(NSDictionary *)params
                        identifier:(NSString *)identifier;

@end
