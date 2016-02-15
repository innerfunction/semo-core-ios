//
//  IFNavigationViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFNavigationViewController.h"
#import "IFTargetContainerViewController.h"
#import "IFLogging.h"

@interface IFNavigationViewController()

- (void)updateContainerBehaviourState;

@end

@implementation IFNavigationViewController

@synthesize parentTargetContainer;

- (id)init {
    self = [super init];
    if (self) {
        containerBehaviour = [[IFDefaultTargetContainerBehaviour alloc] init];
        containerBehaviour.owner = self;
    }
    return self;
}

- (void)setRootView:(UIViewController *)rootView {
    self.viewControllers = @[ rootView ];
    [self updateContainerBehaviourState];
}

- (UIViewController *)getRootView {
    if ([self.viewControllers count] > 0) {
        return [self.viewControllers objectAtIndex:0];
    }
    return nil;
}

- (id<IFURIHandler>)uriHandler {
    return containerBehaviour.uriHandler;
}

- (void)setUriHandler:(id<IFURIHandler>)uriHandler {
    containerBehaviour.uriHandler = uriHandler;
}

- (void)setUriRewriteRules:(IFStringRewriteRules *)uriRewriteRules {
    _uriRewriteRules = uriRewriteRules;
    containerBehaviour.uriRewriteRules = uriRewriteRules;
}

- (void)setNamedTargets:(NSDictionary *)namedTargets {
    containerBehaviour.namedTargets = namedTargets;
}

- (NSDictionary *)getNamedTargets {
    return containerBehaviour.namedTargets;
}

- (BOOL)dispatchURI:(NSString *)uri {
    return [containerBehaviour dispatchURI:uri];
}

- (void)doAction:(IFDoAction *)action {
    if ([@"open" isEqualToString:action.name]) {
        UIViewController *view = nil;
        // Resolve the view to a view controller instance.
        id _view = [action.parameters valueForKey:@"view"];
        /*
        if ([_view isKindOfClass:[IFResource class]]) {
            _view = ((IFResource *)_view).data;
        }
        */
        if ([_view isKindOfClass:[UIViewController class]]) {
            view = (UIViewController *)_view;
        }
        else if ([_view isKindOfClass:[UIView class]]) {
            view = [[IFTargetContainerViewController alloc] initWithView:(UIView *)_view];
        }
        // Push the new view.
        if (view) {
            [self pushViewController:view animated:YES];
        }
        else {
            DDLogWarn(@"%@: Unable to push view parameter of type %@", LogTag, [view.class description]);
        }
    }
    else if ([@"back" isEqualToString:action.name]) {
        [self popViewControllerAnimated:YES];
    }
}

- (NSDictionary *)namedTargets {
    return [NSDictionary dictionary];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:YES];
    [self updateContainerBehaviourState];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *popped = [super popViewControllerAnimated:animated];
    [self updateContainerBehaviourState];
    return popped;
}

#pragma mark - private

- (void)updateContainerBehaviourState {
    if ([self.topViewController conformsToProtocol:@protocol(IFTargetContainer)]) {
        id<IFTargetContainer> container = (id<IFTargetContainer>)self.topViewController;
        container.parentTargetContainer = self;
        containerBehaviour.namedTargets = container.namedTargets;
    }
    else {
        containerBehaviour.namedTargets = [NSDictionary dictionary];
    }
}

@end
