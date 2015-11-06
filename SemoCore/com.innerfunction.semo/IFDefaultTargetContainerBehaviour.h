//
//  IFViewContainerBehaviour.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFTargetContainer.h"
#import "IFStringRewriteRules.h"

@interface IFDefaultTargetContainerBehaviour : NSObject <IFTargetContainer>

/** The behaviour's owner. */
@property (nonatomic, strong) id owner;
/** Action URI rewrite rules. */
@property (nonatomic, strong) IFStringRewriteRules *uriRewriteRules;

/**
 * Resolve a child or descendant target from a target path.
 * Returns the behaviour's owner for empty paths; returns nill if a path can't be resolved.
 */
- (id)targetForPath:(NSString *)targetPath;

@end
