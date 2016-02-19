//
//  IFTargetContainerViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFTargetContainerViewController.h"
#import "IFLogging.h"
#import "UIViewController+Toast.h"

@interface IFTargetContainerViewController()

- (void)doViewInitialization;
- (void)insertNamedViews;
- (void)replaceSubview:(UIView *)view withView:(UIView *)view;

@end

@implementation IFTargetContainerViewController

- (id)init {
    self = [super init];
    if (self) {
        containerBehaviour = [[IFDefaultTargetContainerBehaviour alloc] init];
        containerBehaviour.owner = self;
        _namedViews = [NSDictionary dictionary];
        [self doViewInitialization];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    self = [self init];
    if (self) {
        self.view = view;
        [self doViewInitialization];
    }
    return self;
}

- (void)doViewInitialization {
    // If no view already specified and a layout name has been specified then load the nib file of
    // that name.
    if (!self.view && _layoutName) {
        NSArray *result = [[NSBundle mainBundle] loadNibNamed:_layoutName owner:self options:nil];
        if ([result count] > 0) {
            [self insertNamedViews];
        }
        else {
            DDLogWarn(@"%@: Unable to load nib file %@.xib", LogTag, _layoutName);
        }
    }
}

- (id<IFTargetContainer>)parentTargetContainer {
    return containerBehaviour.parentTargetContainer;
}

- (void)setParentTargetContainer:(id<IFTargetContainer>)parentTargetContainer {
    containerBehaviour.parentTargetContainer = parentTargetContainer;
    // TODO: Confirm following isn't needed.
    // self.uriHandler = parentTargetContainer.uriHandler;
}

- (id<IFURIHandler>)uriHandler {
    return containerBehaviour.uriHandler;
}

- (void)setUriHandler:(id<IFURIHandler>)uriHandler {
    containerBehaviour.uriHandler = uriHandler;
}

- (void)setNamedViews:(NSDictionary *)namedViews {
    _namedViews = namedViews;
    self.namedTargets = namedViews;
}

- (void)setUriRewriteRules:(IFStringRewriteRules *)uriRewriteRules {
    _uriRewriteRules = uriRewriteRules;
    containerBehaviour.uriRewriteRules = uriRewriteRules;
}

- (void)setNamedTargets:(NSDictionary *)namedTargets {
    _namedTargets = namedTargets;
    containerBehaviour.namedTargets = namedTargets;
}

- (BOOL)dispatchURI:(NSString *)uri {
    return [containerBehaviour dispatchURI:uri];
}

- (void)doAction:(IFDoAction *)action {
    if ([@"open" isEqualToString:action.name]) {
        id view = [action.parameters valueForKey:@"view"];
        if ([view isKindOfClass:[UIView class]]) {
            // TODO: Animated view transitions; add a class property allowing the transition type to be specified.
            self.view = view;
        }
    }
    else if ([@"toast" isEqualToString:action.name]) {
        NSString *message = [[action.parameters valueForKey:@"message"] description];
        if (message) {
            [self showToastMessage:message];
        }
    }
}

#pragma mark - private

- (void)insertNamedViews {
    for (NSString *name in [_namedViews keyEnumerator]) {
        id view = [_namedViews objectForKey:name];
        id tag = [_namedViewTags objectForKey:name];
        // Find the placeholder view in the layout.
        UIView *placeholder = nil;
        if (tag) {
            NSInteger _tag = ((NSNumber *)tag).integerValue;
            placeholder = [self.view viewWithTag:_tag];
        }
        // Replace the placeholder with the named view.
        if (placeholder) {
            if ([view isKindOfClass:[UIView class]]) {
                [self replaceSubview:placeholder withView:view];
            }
            else if ([view isKindOfClass:[UIViewController class]]) {
                UIViewController *controller = (UIViewController *)view;
                [self addChildViewController:controller];
                [self replaceSubview:placeholder withView:controller.view];
            }
            else {
                DDLogWarn(@"%@: Can't insert named view '%@' of class '%@'", LogTag, name, [[view class] description]);
            }
        }
        else {
            DDLogWarn(@"%@: Can't find placeholder view for tag %@", LogTag, tag);
        }
    }
}

- (void)replaceSubview:(UIView *)subview withView:(UIView *)view {
    // Copy frame and bounds
    view.frame = subview.frame;
    view.bounds = subview.bounds;
    // Copy layout params to the new view
    view.autoresizingMask = subview.autoresizingMask;
    view.autoresizesSubviews = subview.autoresizesSubviews;
    view.contentMode = subview.contentMode;
    // Swap the views.
    UIView *superview = subview.superview;
    NSUInteger idx = [superview.subviews indexOfObject:subview];
    [subview removeFromSuperview];
    [superview insertSubview:view atIndex:idx];
}

@end
