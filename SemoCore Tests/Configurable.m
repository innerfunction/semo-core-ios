//
//  Configurable.m
//  SemoCore
//
//  Created by Julian Goacher on 25/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "Configurable.h"

@implementation Configurable

- (void)configure:(IFConfiguration *)configuration {
    self.value = [configuration getValueAsString:@"value2"];
    self.configured = YES;
}

@end
