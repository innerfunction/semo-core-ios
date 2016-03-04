//
//  IFIOCConfigurer.h
//  SemoCore
//
//  Created by Julian Goacher on 04/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Protocol for configurable proxies.
 * Configurable proxies present properties which are used in turn to configure another object.
 * Proxies are useful when 
@protocol IFIOCConfigurer <NSObject>

- (id)initWithObject:(id)object;
- (id)getConfiguredObject;

@end
