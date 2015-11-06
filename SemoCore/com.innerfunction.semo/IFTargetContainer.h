//
//  IFViewContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFActionDispatcher.h"
#import "IFURIHandling.h"

/**
 * Protocol for objects which wish contain action targets.
 */
@protocol IFTargetContainer <IFActionDispatcher>

/** This container's parent container. */
@property (nonatomic, strong) id<IFTargetContainer> parentTargetContainer;
/** This container's named targets. */
@property (nonatomic, strong) NSDictionary *namedTargets;
/** A URI handler. */
@property (nonatomic, strong) id<IFURIHandler> uriHandler;

@end
