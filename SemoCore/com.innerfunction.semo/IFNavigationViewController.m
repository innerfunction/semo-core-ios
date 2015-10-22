//
//  IFNavigationViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFNavigationViewController.h"
#import "IFContainerViewController.h"
#import "IFLogging.h"

@implementation IFNavigationViewController

@synthesize parentActionTargetContainer;

- (id)init {
    self = [super init];
    if (self) {
        containerBehaviour = [[IFActionTargetContainerBehaviour alloc] init];
        containerBehaviour.owner = self;
    }
    return self;
}

- (void)setUriRewriteRules:(IFStringRewriteRules *)uriRewriteRules {
    _uriRewriteRules = uriRewriteRules;
    containerBehaviour.uriRewriteRules = uriRewriteRules;
}

- (BOOL)dispatchURI:(NSString *)uri {
    return [containerBehaviour dispatchURI:uri];
}

- (void)doAction:(IFDoAction *)action {
    if ([@"open" isEqualToString:action.name]) {
        UIViewController *view = nil;
        // Resolve the view to a view controller instance.
        id _view = [action.parameters valueForKey:@"view"];
        if ([_view isKindOfClass:[UIViewController class]]) {
            view = (UIViewController *)_view;
        }
        else if ([_view isKindOfClass:[UIView class]]) {
            view = [[IFContainerViewController alloc] initWithView:(UIView *)_view];
        }
        
        // TODO: The maintenance of the container heirarchies has to be review in this class
        // and in IFActionTargetContainerBehaviour. The idea in this case is that the navigation
        // controller is a thin wrapper for the topmost view container.
        
        // Plug the new view into the container heirarchy if it is itself a container.
        if ([view conformsToProtocol:@protocol(IFActionTargetContainer)]) {
            id<IFActionTargetContainer> container = (id<IFActionTargetContainer>)view;
            container.parentActionTargetContainer = self;
            [containerBehaviour setNamedTargets:[container namedTargets]];
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

@end
