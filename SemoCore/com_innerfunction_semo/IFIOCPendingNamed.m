//
//  IFIOCNamedDependencyPlaceholder.m
//  SemoCore
//
//  Created by Julian Goacher on 14/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFIOCPendingNamed.h"

@implementation IFIOCPendingNamed

- (void)setObject:(id)object {
    _object = object;
    _objectKey = [NSValue valueWithNonretainedObject:object];
}

- (id)resolveValue:(id)value {
    // If a reference path is set then use it to fully resolve the pending value on the named object.
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
