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

- (void)setRootView:(UIViewController *)rootView {
    self.viewControllers = @[ rootView ];
}

- (UIViewController *)getRootView {
    if ([self.viewControllers count] > 0) {
        return [self.viewControllers objectAtIndex:0];
    }
    return nil;
}

- (BOOL)handlePostAction:(IFPostAction *)postAction sender:(id)sender {
    if ([@"open" isEqualToString:postAction.message]) {
        UIViewController *view = nil;
        // Resolve the view to a view controller instance.
        id maybeView = [postAction.parameters valueForKey:@"view"];
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
            [self pushViewController:view animated:YES];
        }
        else {
            DDLogWarn(@"%@: Unable to push view parameter of type %@", LogTag, [view.class description]);
        }
        return YES;
    }
    else if ([@"back" isEqualToString:postAction.message]) {
        [self popViewControllerAnimated:YES];
        return YES;
    }
    return NO;
}

@end
