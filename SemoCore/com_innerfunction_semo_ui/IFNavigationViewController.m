//
//  IFNavigationViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFNavigationViewController.h"
#import "IFViewController.h"
#import "IFLogging.h"

@implementation IFNavigationViewController

#pragma mark - Overrides

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    if (_panGestureRecognizer) {
        [viewController.view addGestureRecognizer:_panGestureRecognizer];
    }
}

#pragma mark - Instance methods

- (void)replaceBackSwipeGesture:(UIPanGestureRecognizer *)recognizer {
    [self.view removeGestureRecognizer:self.interactivePopGestureRecognizer];
    _panGestureRecognizer = recognizer;
    // Set the new gesture recognizer on any view's already on the navigation stack.
    for (UIViewController *viewController in self.viewControllers) {
        [viewController.view addGestureRecognizer:_panGestureRecognizer];
    }
}

- (void)setRootView:(UIViewController *)rootView {
    self.viewControllers = @[ rootView ];
}

- (UIViewController *)getRootView {
    if ([self.viewControllers count] > 0) {
        return [self.viewControllers objectAtIndex:0];
    }
    return nil;
}

- (void)setTitleBarColor:(UIColor *)titleBarColor {
    _titleBarColor = titleBarColor;
    self.navigationBar.barTintColor = titleBarColor;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor;
    self.navigationBar.tintColor = titleTextColor;
    self.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: titleTextColor };
}

- (BOOL)handleMessage:(IFMessage *)message sender:(id)sender {
    // NOTE: 'open' is deprecated.
    if ([message hasName:@"show"] || [message hasName:@"open"]) {
        UIViewController *view = nil;
        // Resolve the view to a view controller instance.
        id maybeView = [message.parameters valueForKey:@"view"];
        /*
        if ([maybeView isKindOfClass:[IFResource class]]) {
            maybeView = ((IFResource *)maybeView).data;
        }
        */
        if ([maybeView isKindOfClass:[UIViewController class]]) {
            view = (UIViewController *)maybeView;
        }
        else if ([maybeView isKindOfClass:[UIView class]]) {
            view = [[IFViewController alloc] initWithView:(UIView *)maybeView];
        }
        // Push the new view.
        if (view) {
            if ([@"reset" isEqualToString:[message parameterValue:@"navigation"]]) {
                NSArray *viewControllers = @[ [self.viewControllers firstObject], view ];
                [self setViewControllers:viewControllers animated:YES];
            }
            else {
                [self pushViewController:view animated:YES];
            }
        }
        else {
            DDLogWarn(@"%@: Unable to push view parameter of type %@", LogTag, [view.class description]);
        }
        return YES;
    }
    else if ([message hasName:@"back"]) {
        [self popViewControllerAnimated:YES];
        return YES;
    }
    return NO;
}

@end
