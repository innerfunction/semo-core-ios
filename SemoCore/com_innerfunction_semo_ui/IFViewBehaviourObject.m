//
//  IFViewBehaviourObject.m
//  SemoCore
//
//  Created by Julian Goacher on 12/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFViewBehaviourObject.h"

@implementation IFViewBehaviourObject

@synthesize viewController=_viewController;

- (void)viewDidAppear {}

- (BOOL)handleMessage:(IFMessage *)message sender:(id)sender {
    return NO;
}

@end
