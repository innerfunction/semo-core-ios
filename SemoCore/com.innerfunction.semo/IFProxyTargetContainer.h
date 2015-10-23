//
//  IFProxyTargetContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 23/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFTargetContainer.h"
#import "IFTarget.h"

/**
 * Class for creating target container proxies.
 * This can be useful when a container wants to take responsibility for some of its
 * child container behaviours.
 */
@interface IFProxyTargetContainer : NSObject <IFTargetContainer, IFTarget>

@property (nonatomic, strong) id<IFTarget> target;

- (id)initWithParentContainer:(id<IFTargetContainer>)parent;

@end
