//
//  IFViewContainerController.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFContainerViewController.h"

// TODO: Does name need to be reconsidered?
// TODO: Need to incorporate layout code from EPCore
@implementation IFContainerViewController

@synthesize parentActionTargetContainer;

- (id)init {
    self = [super init];
    if (self) {
        containerBehaviour = [[IFActionTargetContainerBehaviour alloc] init];
        containerBehaviour.owner = self;
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
            // TODO: Animated view transitions.
            self.view = view;
        }
    }
}

@end
