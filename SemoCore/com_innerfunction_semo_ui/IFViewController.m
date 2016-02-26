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

@interface IFViewController()

- (void)doViewInitialization;
- (void)insertNamedViews;
- (void)replaceSubview:(UIView *)view withView:(UIView *)view;

@end

@implementation IFViewController

@synthesize iocContainer = _iocContainer;

- (id)init {
    self = [super init];
    if (self) {
        _hideTitleBar = NO;
        _namedViews = [NSDictionary dictionary];
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
        [self doViewInitialization];
    }
    return self;
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_onShow) {
        _onShow(self);
    }
}

#pragma mark - Instance methods

- (void)postAction:(NSString *)action {
    if (_uriRewriteRules) {
        action = [_uriRewriteRules rewriteString:action];
    }
    [_iocContainer postAction:action sender:self];
}

#pragma mark - IFPostActionHandler protocol

- (BOOL)handlePostAction:(IFPostAction *)postAction sender:(id)sender {
    if ([@"toast" isEqualToString:postAction.message]) {
        NSString *message = [[postAction.parameters valueForKey:@"message"] description];
        if (message) {
            [self showToastMessage:message];
        }
        return YES;
    }
    return NO;
}

#pragma mark - private

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
