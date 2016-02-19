//
//  IFConfigurable.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFConfiguration.h"

/**
 * Protocol for objects which wish to control their own configuration.
 */
@protocol IFConfigurable <NSObject>

/** Configure the object using the specified configuration. */
- (void)configure:(IFConfiguration *)configuration;

@end
