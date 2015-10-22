//
//  IFSlideViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFSlideViewController.h"
#import "IFContainerViewController.h"

@implementation IFSlideViewController

@synthesize parentActionTargetContainer;

- (id)init {
    self = [super init];
    if (self) {
        containerBehaviour = [[IFActionTargetContainerBehaviour alloc] init];
        containerBehaviour.owner = self;
        namedTargets = [[NSMutableDictionary alloc] init];
        self.slidePosition = @"left";
    }
    return self;
}

- (void)setSlideView:(id)slideView {
    if ([slideView isKindOfClass:[UIView class]]) {
        slideView = [[IFContainerViewController alloc] initWithView:(UIView *)slideView];
    }
    if ([slideView isKindOfClass:[UIViewController class]]) {
        _slideView = slideView;
        self.rearViewController = slideView;
        [namedTargets setObject:slideView forKey:@"slide"];
        containerBehaviour.namedTargets = namedTargets;
    }
}

- (void)setMainView:(id)mainView {
    if ([mainView isKindOfClass:[UIView class]]) {
        mainView = [[IFContainerViewController alloc] initWithView:(UIView *)mainView];
    }
    if ([mainView isKindOfClass:[UIViewController class]]) {
        _mainView = mainView;
        self.frontViewController = mainView;
        [namedTargets setObject:mainView forKey:@"main"];
        containerBehaviour.namedTargets = namedTargets;
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
    if ([@"open-slide" isEqualToString:action.name]) {
        self.frontViewPosition = slideOpenPosition;
        
    }
    else if ([@"close-slide" isEqualToString:action.name]) {
        self.frontViewPosition = slideClosedPosition;
    }
    else if ([_mainView conformsToProtocol:@protocol(IFActionTarget)]) {
        // Forward action to the main view.
        [((id<IFActionTarget>)_mainView) doAction:action];
    }
}

- (NSDictionary *)namedTargets {
    return namedTargets;
}

@end
