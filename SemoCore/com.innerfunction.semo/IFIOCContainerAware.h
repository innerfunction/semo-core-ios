//
//  IFIOCContainerAware.h
//  SemoCore
//
//  Created by Julian Goacher on 26/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFContainer.h"

/** An IOC component aware of its container. */
@protocol IFIOCContainerAware <NSObject>

@property (nonatomic, strong) IFContainer *iocContainer;

@end
