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

/** The layout name. Corresponds to the name of a nib file. */
@property (nonatomic, strong) NSString *layoutName;
/** Map of named view components. */
@property (nonatomic, strong) NSDictionary *namedViews;
/** Map of named view names onto nib file view tags. */
@property (nonatomic, strong) NSDictionary *namedViewTags;
/** Action URI rewrite rules. */
@property (nonatomic, strong) IFStringRewriteRules *uriRewriteRules;
/** The named targets contained by this container. */
@property (nonatomic, strong) NSDictionary *namedTargets;

@end
