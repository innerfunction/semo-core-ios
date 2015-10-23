//
//  IFTargetContainerViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTargetContainer.h"
#import "IFTarget.h"
#import "IFDefaultTargetContainerBehaviour.h"

@interface IFTargetContainerViewController : UIViewController <IFTargetContainer, IFTarget> {
    IFDefaultTargetContainerBehaviour *containerBehaviour;
}

- (id)initWithView:(UIView *)view;

/** Action URI rewrite rules. */
@property (nonatomic, strong) IFStringRewriteRules *uriRewriteRules;
/** The named targets contained by this container. */
@property (nonatomic, strong) NSDictionary *namedTargets;

@end
