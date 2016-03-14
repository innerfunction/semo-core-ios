//
//  IFIOCNamedDependencyPlaceholder.m
//  SemoCore
//
//  Created by Julian Goacher on 14/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFIOCPendingNamed.h"

@implementation IFIOCPendingNamed

- (id)initWithNamed:(NSString *)named {
    self = [super init];
    if (self) {
        _named = named;
    }
    return self;
}

- (id)resolveValue:(id)value {
    if (_referencePath) {
        if ([value respondsToSelector:@selector(valueForKeyPath:)]) {
            value = [value valueForKeyPath:_referencePath];
        }
        else {
            value = nil;
        }
    }
    return value;
}

@end
