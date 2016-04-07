// Copyright 2016 InnerFunction Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Julian Goacher on 11/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFViewController.h"
#import "IFAppContainer.h"
#import "IFLogging.h"
#import "UIViewController+Toast.h"
#import "UIViewController+ImageView.h"

@implementation IFViewController

@synthesize iocContainer = _iocContainer, behaviours = _behaviours;

- (id)init {
    self = [super init];
    if (self) {
        _hideTitleBar = NO;
        _namedViews = @{};
        _actionProxyLookup = [NSMutableDictionary new];
        _behaviours = @[];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    self = [self init];
    if (self) {
        self.view = view;
    }
    return self;
}

#pragma mark - IFIOCContainerAware protocol

- (void)beforeIOCConfiguration:(IFConfiguration *)configuration {
    _layoutName = [configuration getValueAsString:@"layoutName" defaultValue:_layoutName];
    [self loadLayout];
}

- (void)afterIOCConfiguration:(IFConfiguration *)configuration {
    [self replaceViewPlaceholders];
}

#pragma mark - IFViewBehaviourController protocol

- (void)setBehaviour:(id<IFViewBehaviour>)behaviour {
    if (behaviour != nil) {
        self.behaviours = @[ behaviour ];
    }
}

- (id<IFViewBehaviour>)behaviour {
    return [self.behaviours firstObject];
}

- (void)setBehaviours:(NSArray *)behaviours {
    _behaviours = behaviours;
    for (id<IFViewBehaviour> behaviour in _behaviours) {
        behaviour.viewController = self;
    }
}

- (void)addBehaviour:(id<IFViewBehaviour>)behaviour {
    if (behaviour) {
        _behaviours = [_behaviours arrayByAddingObject:behaviour];
    }
}

#pragma mark - Lifecycle methods

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = _hideTitleBar;
    [super viewWillAppear:animated];
    if (_backButtonTitle) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_backButtonTitle
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:nil];
    }
    if (_leftTitleBarButton) {
        self.navigationItem.leftBarButtonItem = _leftTitleBarButton;
    }
    if (_rightTitleBarButton) {
        self.navigationItem.rightBarButtonItem = _rightTitleBarButton;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    for (id<IFViewBehaviour> behaviour in _behaviours) {
        [behaviour viewDidAppear];
    }
}

#pragma mark - Instance methods

- (void)postMessage:(NSString *)message {
    [IFAppContainer postMessage:message sender:self];
}

#pragma mark - IFMessageReceiver protocol

- (BOOL)receiveMessage:(IFMessage *)message sender:(id)sender {
    for (id<IFViewBehaviour> behaviour in _behaviours) {
        if ([behaviour receiveMessage:message sender:sender]) {
            return YES;
        }
    }
    if ([message hasName:@"toast"]) {
        NSString *toastMessage = [message parameterValue:@"message"];
        if (toastMessage) {
            [self showToastMessage:toastMessage];
        }
        return YES;
    }
    if ([message hasName:@"show-image"]) {
        NSString *url = [message parameterValue:@"url"];
        if (url) {
            [self showImageAtURL:[NSURL URLWithString:url] referenceView:self.view];
        }
    }
    return NO;
}

#pragma mark - IFActionProxy

- (void)registerAction:(NSString *)action forObject:(id)object {
    NSValue *key = [NSValue valueWithNonretainedObject:object];
    _actionProxyLookup[key] = action;
}

- (void)postActionForObject:(id)object {
    NSValue *key = [NSValue valueWithNonretainedObject:object];
    NSString *action = _actionProxyLookup[key];
    if (action) {
        [self postMessage:action];
    }
}

#pragma mark - Key-Value coding

- (void)setValue:(id)value forKey:(NSString *)key {
    // The layout will use this method when passing view instances to their referencing
    // outlets.
    // (See https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/LoadingResources/CocoaNibs/CocoaNibs.html#//apple_ref/doc/uid/10000051i-CH4-SW19)
    // Use this to keep track of view placeholders.
    if (_loadingLayout) {
        [_namedViewPlaceholders setObject:value forKey:key];
    }
    [super setValue:value forKey:key];
}

#pragma mark - private

- (void)loadLayout {
    // If no view already specified and a layout name has been specified then load the nib file of
    // that name.
    if (_layoutName) {
        _namedViewPlaceholders = [NSMutableDictionary new];
        _loadingLayout = YES;
        NSArray *result = [[NSBundle mainBundle] loadNibNamed:_layoutName owner:self options:nil];
        if (![result count]) {
            DDLogWarn(@"%@: Failed to load layout from %@.xib", LogTag, _layoutName);
        }
        else {
            self.view = result[0];
        }
        _loadingLayout = NO;
    }
}

- (void)replaceViewPlaceholders {
    for (NSString *name in _namedViewPlaceholders) {
        id view = [_namedViews objectForKey:name];
        if (!view) {
            view = [self valueForKey:name];
        }
        if (view) {
            UIView *placeholder = [_namedViewPlaceholders objectForKey:name];
            // Replace the placeholder with the named view.
            if ([view isKindOfClass:[UIView class]]) {
                [self replaceSubview:placeholder withView:view];
            }
            else if ([view isKindOfClass:[UIViewController class]]) {
                UIViewController *controller = (UIViewController *)view;
                [self addChildViewController:controller];
                [self replaceSubview:placeholder withView:controller.view];
            }
            else {
                DDLogWarn(@"%@: Named view '%@' has non-view class '%@'", LogTag, name, [view class]);
            }
        }
        else {
            DDLogWarn(@"%@: No placeholder for named view '%@'", LogTag, name);
        }
    }
    // Discard the placeholder views.
    _namedViewPlaceholders = nil;
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
