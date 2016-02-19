//
//  IFIOCConfigurationInitable.h
//  SemoCore
//
//  Created by Julian Goacher on 26/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFConfiguration.h"

/** Protocol for classes which can be initialized with a configuration. */
@protocol IFIOCConfigurationInitable <NSObject>

- (id)initWithConfiguration:(IFConfiguration *)config;

@end
