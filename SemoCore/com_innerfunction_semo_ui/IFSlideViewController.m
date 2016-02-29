//
//  IFSlideViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFSlideViewController.h"
#import "IFViewController.h"
#import "IFNavigationViewController.h"

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
        //[self setFrontViewController:mainView animated:YES];
        
        // Set gesture receive on main view.
        if ([mainView isKindOfClass:[IFNavigationViewController class]]) {
            [(IFNavigationViewController *)mainView replaceBackSwipeGesture:self.panGestureRecognizer];
        }
        else {
            [((UIViewController *)mainView).view addGestureRecognizer:self.panGestureRecognizer];
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

#pragma mark - IFMessageTargetContainer

- (BOOL)dispatchMessage:(IFMessage *)message sender:(id)sender {
    BOOL dispatched = NO;
    if ([message hasTarget:@"slide"]) {
        message = [message popTargetHead];
        if ([message hasEmptyTarget] && [self.slideView conformsToProtocol:@protocol(IFMessageHandler)]) {
            dispatched = [(id<IFMessageHandler>)self.slideView handleMessage:message sender:sender];
        }
        else if ([self.slideView conformsToProtocol:@protocol(IFMessageTargetContainer)]) {
            dispatched = [(id<IFMessageTargetContainer>)self.slideView dispatchMessage:message sender:sender];
        }
    }
    else if ([message hasTarget:@"main"]) {
        message = [message popTargetHead];
        if ([message hasEmptyTarget] && [self.mainView conformsToProtocol:@protocol(IFMessageHandler)]) {
            dispatched = [(id<IFMessageHandler>)self.mainView handleMessage:message sender:sender];
        }
        else if ([self.mainView conformsToProtocol:@protocol(IFMessageTargetContainer)]) {
            dispatched = [(id<IFMessageTargetContainer>)self.mainView dispatchMessage:message sender:sender];
        }
        self.frontViewPosition = slideClosedPosition;
    }
    return dispatched;
}

#pragma mark - IFMessageHandler

- (BOOL)handleMessage:(IFMessage *)message sender:(id)sender {
    // NOTE 'open' is deprecated. Note also other deprecations below.
    if ([message hasName:@"show"] || [message hasName:@"open"]) {
        // Replace main view.
        self.mainView = [message.parameters valueForKey:@"view"];
        return YES;
    }
    if ([message hasName:@"show-in-slide"] || [message hasName:@"open-in-slide"]) {
        // Replace the slide view.
        self.slideView = [message.parameters valueForKey:@"view"];
    }
    if ([message hasName:@"open-slide"] || [message hasName:@"show-slide"]) {
        // Open the slide view.
        self.frontViewPosition = slideOpenPosition;
        return YES;
    }
    if ([message hasName:@"close-slide"] || [message hasName:@"hide-slide"]) {
        // Close the slide view.
        self.frontViewPosition = slideClosedPosition;
        return YES;
    }
    return NO;
}

@end
