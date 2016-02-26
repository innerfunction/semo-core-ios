//
//  IFSlideViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFSlideViewController.h"
#import "IFViewController.h"

@implementation IFSlideViewController

- (id)init {
    self = [super init];
    if (self) {
        self.slidePosition = @"left";
    }
    return self;
}

- (void)setSlideView:(id)slideView {
    if ([slideView isKindOfClass:[UIView class]]) {
        slideView = [[IFViewController alloc] initWithView:(UIView *)slideView];
    }
    if ([slideView isKindOfClass:[UIViewController class]]) {
        _slideView = slideView;
        self.rearViewController = slideView;
    }
}

- (void)setMainView:(id)mainView {
    if ([mainView isKindOfClass:[UIView class]]) {
        mainView = [[IFViewController alloc] initWithView:(UIView *)mainView];
    }
    if ([mainView isKindOfClass:[UIViewController class]]) {
        _mainView = mainView;
        self.frontViewController = mainView;
        
        // Set gesture receive on main view.
        UIView *gestureReceiver = nil;
        if ([mainView isKindOfClass:[UINavigationController class]]) {
            gestureReceiver = [(UINavigationController *)mainView topViewController].view;
            // TODO: What happens when user navigates to a new view?
        }
        else if ([mainView isKindOfClass:[UIViewController class]]) {
            gestureReceiver = ((UIViewController *)mainView).view;
        }
        if (gestureReceiver) {
            [gestureReceiver addGestureRecognizer:[self panGestureRecognizer]];
        }
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
    self.frontViewPosition = slideOpenPosition;
}

- (void)dispatchAction:(IFPostAction *)postAction sender:(id)sender {
    if ([postAction hasEmptyTarget]) {
        [self handlePostAction:postAction sender:sender];
    }
    else if ([postAction hasTarget:@"slide"]) {
        postAction = [postAction popTargetHead];
        if ([postAction hasEmptyTarget] && [self.slideView conformsToProtocol:@protocol(IFPostActionHandler)]) {
            [(id<IFPostActionHandler>)self.slideView handlePostAction:postAction sender:sender];
        }
        else if ([self.slideView conformsToProtocol:@protocol(IFPostActionTargetContainer)]) {
            [(id<IFPostActionTargetContainer>)self.slideView dispatchAction:postAction sender:sender];
        }
    }
    else if ([postAction hasTarget:@"main"]) {
        postAction = [postAction popTargetHead];
        if ([postAction hasEmptyTarget] && [self.mainView conformsToProtocol:@protocol(IFPostActionHandler)]) {
            [(id<IFPostActionHandler>)self.mainView handlePostAction:postAction sender:sender];
        }
        else if ([self.mainView conformsToProtocol:@protocol(IFPostActionTargetContainer)]) {
            [(id<IFPostActionTargetContainer>)self.mainView dispatchAction:postAction sender:sender];
        }
        self.frontViewPosition = slideClosedPosition;
    }
}

- (BOOL)handlePostAction:(IFPostAction *)postAction sender:(id)sender {
    if ([@"open" isEqualToString:postAction.message]) {
        // Replace main view.
        self.mainView = [postAction.parameters valueForKey:@"view"];
        return YES;
    }
    if ([@"open-in-slide" isEqualToString:postAction.message]) {
        // Replace the slide view.
        self.slideView = [postAction.parameters valueForKey:@"view"];
    }
    if ([@"show-slide" isEqualToString:postAction.message]) {
        // Open the slide view.
        self.frontViewPosition = slideOpenPosition;
        return YES;
    }
    if ([@"hide-slide" isEqualToString:postAction.message]) {
        // Close the slide view.
        self.frontViewPosition = slideClosedPosition;
        return YES;
    }
    return NO;
}

@end
