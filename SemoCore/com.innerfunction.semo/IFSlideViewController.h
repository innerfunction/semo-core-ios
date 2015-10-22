//
//  IFSlideViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "SWRevealViewController.h"
#import "IFActionTargetContainer.h"
#import "IFActionTarget.h"
#import "IFActionTargetContainerBehaviour.h"

@interface IFSlideViewController : SWRevealViewController <IFActionTargetContainer, IFActionTarget> {
    IFActionTargetContainerBehaviour *containerBehaviour;
    NSMutableDictionary *namedTargets;
    FrontViewPosition slideOpenPosition;
    FrontViewPosition slideClosedPosition;
}

/** Action URI rewrite rules. */
@property (nonatomic, strong) IFStringRewriteRules *uriRewriteRules;
/** The slide view. */
@property (nonatomic, strong) id slideView;
/** The main view. */
@property (nonatomic, strong) id mainView;
/** The position of the slide view. Values can be "left" or "right". */
@property (nonatomic, strong) NSString *slidePosition;

@end
