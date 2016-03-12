//
//  IFViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 11/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFViewController.h"
#import "IFAppContainer.h"
#import "IFLogging.h"
#import "UIViewController+Toast.h"
#import "UIViewController+ImageView.h"

@interface IFViewController()

- (void)doViewInitialization;
- (void)insertNamedViews;
- (void)replaceSubview:(UIView *)view withView:(UIView *)view;

@end

@implementation IFViewController

@synthesize iocContainer = _iocContainer, behaviours = _behaviours;

- (id)init {
    self = [super init];
    if (self) {
        _hideTitleBar = NO;
        _namedViews = [NSDictionary dictionary];
        _actionProxyLookup = [NSMutableDictionary new];
        _behaviours = [NSArray array];
        [self doViewInitialization];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        self.view = view;
        _hideTitleBar = NO;
        _namedViews = [NSDictionary dictionary];
        _actionProxyLookup = [NSMutableDictionary new];
        _behaviours = [NSArray array];
        [self doViewInitialization];
    }
    return self;
}

#pragma mark - IFViewBehaviourController protocol

- (void)setBehaviour:(id<IFViewBehaviour>)behaviour {
    self.behaviours = @[ behaviour ];
}

- (id<IFViewBehaviour>)behaviour {
    return [self.behaviours firstObject];
}

- (void)setBehaviours:(NSArray *)behaviours {
    NSPredicate *isNotNil = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject != nil;
    }];
    _behaviours = [behaviours filteredArrayUsingPredicate:isNotNil];
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

#pragma mark - IFMessageHandler protocol

- (BOOL)handleMessage:(IFMessage *)message sender:(id)sender {
    for (id<IFViewBehaviour> behaviour in _behaviours) {
        if ([behaviour handleMessage:message sender:sender]) {
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

#pragma mark - private

- (void)doViewInitialization {
    // Ensure this code is run on the UI thread.
    // (When the view is being instantiated by an IOC container, view initialization might be invoked
    // from a background thread).
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

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

@end
