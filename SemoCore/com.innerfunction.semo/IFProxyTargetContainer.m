//
//  IFProxyTargetContainer.m
//  SemoCore
//
//  Created by Julian Goacher on 23/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFProxyTargetContainer.h"

@implementation IFProxyTargetContainer

@synthesize parentTargetContainer;

- (id)initWithParentContainer:(id<IFTargetContainer>)parent {
    self = [super init];
    if (self) {
        self.parentTargetContainer = parent;
    }
    return self;
}

- (void)setParentTargetContainer:(id<IFTargetContainer>)_parentTargetContainer {
    parentTargetContainer = _parentTargetContainer;
    if ([parentTargetContainer conformsToProtocol:@protocol(IFTarget)]) {
        self.target = (id<IFTarget>)parentTargetContainer;
    }
}

- (void)setNamedTargets:(NSDictionary *)namedTargets {
    parentTargetContainer.namedTargets = namedTargets;
}

- (NSDictionary *)namedTargets {
    return parentTargetContainer.namedTargets;
}

- (BOOL)dispatchURI:(NSString *)uri {
    return [parentTargetContainer dispatchURI:uri];
}

- (void)doAction:(IFDoAction *)action {
    [_target doAction:action];
}

@end
