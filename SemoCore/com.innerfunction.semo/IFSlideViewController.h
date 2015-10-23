//
//  IFSlideViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "SWRevealViewController.h"
#import "IFTargetContainer.h"
#import "IFTarget.h"
#import "IFDefaultTargetContainerBehaviour.h"

@interface IFSlideViewController : SWRevealViewController <IFTargetContainer, IFTarget> {
    IFDefaultTargetContainerBehaviour *containerBehaviour;
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
