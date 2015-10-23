//
//  IFSlideViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFSlideViewController.h"
#import "IFTargetContainerViewController.h"

@implementation IFSlideViewController

@synthesize parentTargetContainer, namedTargets;

- (id)init {
    self = [super init];
    if (self) {
        slideProxy = [[IFProxyTargetContainer alloc] initWithParentContainer:self];
        mainProxy = [[IFProxyTargetContainer alloc] initWithParentContainer:self];
        self.namedTargets = @{ @"slide": slideProxy, @"main": mainProxy };
        
        containerBehaviour = [[IFDefaultTargetContainerBehaviour alloc] init];
        containerBehaviour.owner = self;
        containerBehaviour.namedTargets = self.namedTargets;
        
        self.slidePosition = @"left";
    }
    return self;
}

- (void)setSlideView:(id)slideView {
    if ([slideView isKindOfClass:[UIView class]]) {
        slideView = [[IFTargetContainerViewController alloc] initWithView:(UIView *)slideView];
    }
    if ([slideView isKindOfClass:[UIViewController class]]) {
        _slideView = slideView;
        self.rearViewController = slideView;
        slideProxy.target = slideView;
    }
}

- (void)setMainView:(id)mainView {
    if ([mainView isKindOfClass:[UIView class]]) {
        mainView = [[IFTargetContainerViewController alloc] initWithView:(UIView *)mainView];
    }
    if ([mainView isKindOfClass:[UIViewController class]]) {
        _mainView = mainView;
        self.frontViewController = mainView;
        mainProxy.target = mainView;
    }
}

- (void)setSlidePosition:(NSString *)slidePosition {
    if ([@"right" isEqualToString:slidePosition]) {
        slideOpenPosition = FrontViewPositionRight;
        slideClosedPosition = FrontViewPositionRightMostRemoved;
    }
    else {
        slideOpenPosition = FrontViewPositionLeft;
        slideClosedPosition = FrontViewPositionLeftSideMostRemoved;
    }
}

- (void)setUriRewriteRules:(IFStringRewriteRules *)uriRewriteRules {
    _uriRewriteRules = uriRewriteRules;
    containerBehaviour.uriRewriteRules = uriRewriteRules;
}

- (BOOL)dispatchURI:(NSString *)uri {
    return [containerBehaviour dispatchURI:uri];
}

- (void)doAction:(IFDoAction *)action {
    if ([@"open" isEqualToString:action.name]) {
        // Open a view in one of this component's child views.
        if ([@"slide" isEqualToString:action.target]) {
            // Replace the slide view.
            self.slideView = [action.parameters valueForKey:@"view"];
        }
        else if ([@"main" isEqualToString:action.target]) {
            // Replace the main view.
            self.mainView = [action.parameters valueForKey:@"view"];
        }
        else if ([_mainView conformsToProtocol:@protocol(IFTarget)]) {
            // Forward action to the main view.
            [((id<IFTarget>)_mainView) doAction:action];
        }
        else {
            // Replace main view.
            self.mainView = [action.parameters valueForKey:@"view"];
        }
    }
    else if ([@"open-slide" isEqualToString:action.name]) {
        // Open the slide view.
        self.frontViewPosition = slideOpenPosition;
    }
    else if ([@"close-slide" isEqualToString:action.name]) {
        // Close the slide view.
        self.frontViewPosition = slideClosedPosition;
    }
    else if ([_mainView conformsToProtocol:@protocol(IFTarget)]) {
        // Forward action to the main view.
        [((id<IFTarget>)_mainView) doAction:action];
    }
}

@end
