//
//  IFViewContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFActionDispatcher.h"

/**
 * Protocol for objects which wish to control their own configuration.
 */
@protocol IFTargetContainer <IFActionDispatcher>

/** Get/set this containers parent. */
@property (nonatomic, strong) id<IFTargetContainer> parentTargetContainer;

/** Get/set this container's named targets. */
@property (nonatomic, strong) NSDictionary *namedTargets;

@end
