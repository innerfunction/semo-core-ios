//
//  IFNavigationViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTargetContainer.h"
#import "IFTarget.h"
#import "IFDefaultTargetContainerBehaviour.h"

@interface IFNavigationViewController : UINavigationController <IFTargetContainer, IFTarget> {
    IFDefaultTargetContainerBehaviour *containerBehaviour;
}

/** The first view in the navigation stack. */
@property (nonatomic, strong) UIViewController *rootView;
/** Action URI rewrite rules. */
@property (nonatomic, strong) IFStringRewriteRules *uriRewriteRules;

@end
