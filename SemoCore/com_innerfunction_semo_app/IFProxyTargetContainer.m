//
//  IFProxyTargetContainer.m
//  SemoCore
//
//  Created by Julian Goacher on 23/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFProxyTargetContainer.h"

@implementation IFProxyTargetContainer

@synthesize parentTargetContainer, uriHandler;

- (id)initWithParentContainer:(id<IFTargetContainer>)parent {
    self = [super init];
    if (self) {
        self.parentTargetContainer = parent;
    }
    return self;
}

- (void)setTarget:(id<IFTarget>)target {
    _target = target;
    if ([target conformsToProtocol:@protocol(IFTargetContainer)]) {
        targetContainer = (id<IFTargetContainer>)target;
    }
    else {
        targetContainer = nil;
    }
}

- (void)setNamedTargets:(NSDictionary *)namedTargets {
    targetContainer.namedTargets = namedTargets;
}

- (NSDictionary *)namedTargets {
    return targetContainer.namedTargets;
}

- (BOOL)dispatchURI:(NSString *)uri {
    return [parentTargetContainer dispatchURI:uri];
}

- (void)doAction:(IFDoAction *)action {
    [_target doAction:action];
}

@end
