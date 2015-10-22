//
//  IFViewContainerBehaviour.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFActionTargetContainer.h"
#import "IFStringRewriteRules.h"
#import "IFURIResolver.h"

@interface IFActionTargetContainerBehaviour : NSObject <IFActionTargetContainer>

/** Get/set the behaviour's owner. */
@property (nonatomic, strong) id owner;
/** Action URI rewrite rules. */
@property (nonatomic, strong) IFStringRewriteRules *uriRewriteRules;
/** A URI resolver. */
@property (nonatomic, strong) id<IFURIResolver> uriResolver;
/** The named targets contained by this container. */
@property (nonatomic, strong) NSDictionary *namedTargets;

@end
