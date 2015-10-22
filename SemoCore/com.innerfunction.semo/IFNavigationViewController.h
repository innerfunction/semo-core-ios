//
//  IFNavigationViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFActionTargetContainer.h"
#import "IFActionTarget.h"
#import "IFActionTargetContainerBehaviour.h"

@interface IFNavigationViewController : UINavigationController <IFActionTargetContainer, IFActionTarget> {
    IFActionTargetContainerBehaviour *containerBehaviour;
}

/** Action URI rewrite rules. */
@property (nonatomic, strong) IFStringRewriteRules *uriRewriteRules;

@end
