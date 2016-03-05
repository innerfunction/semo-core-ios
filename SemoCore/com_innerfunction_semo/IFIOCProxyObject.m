//
//  IFIOCProxyObject.m
//  SemoCore
//
//  Created by Julian Goacher on 04/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFIOCProxyObject.h"

@implementation IFIOCProxyObject

#pragma mark - IFIOCProxy

- (id)initWithPropertyName:(NSString *)propertyName ofObject:(id)object {
    self = [super init];
    if (self) {
        _propertyName = propertyName;
        _object = object;
        _proxiedValue = _object[_propertyName];
        _isNewValue = (_proxiedValue == nil);
    }
    return self;
}

#pragma mark - IFIOCConfigurable

- (void)beforeConfiguration:(IFConfiguration *)configuration inContainer:(IFContainer *)container {}

- (void)afterConfiguration:(IFConfiguration *)configuration inContainer:(IFContainer *)container {
    if (_isNewValue) {
        id value = self.proxiedValue;
        if (value != nil) {
            _object[_propertyName] = value;
        }
    }
}

@end
