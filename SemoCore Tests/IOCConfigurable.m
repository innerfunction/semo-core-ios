//
//  IOCConfigurable.m
//  SemoCore
//
//  Created by Julian Goacher on 25/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IOCConfigurable.h"

@implementation IOCConfigurable

- (void)beforeConfigure:(IFContainer *)container {
    self.beforeConfigureCalled = (self.value == nil);
}

- (void)afterConfigure:(IFContainer *)container {
    self.afterConfigureCalled = (self.value != nil);
}

@end
