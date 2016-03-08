//
//  IFUIBarButtonItemProxy.m
//  SemoCore
//
//  Created by Julian Goacher on 08/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFUIBarButtonItemProxy.h"
#import "IFActionProxy.h"
#import "IFContainer.h"

@implementation IFUIBarButtonItemProxy

- (id)init {
    self = [super init];
    if (self) {
        _barButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                          style:UIBarButtonItemStylePlain
                                                         target:nil
                                                         action:nil];
    }
    return self;
}

- (id)initWithValue:(id)value {
    self = [super init];
    if (self) {
        _barButtonItem = (UIBarButtonItem *)value;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _barButtonItem.title = title;
}

- (NSString *)title {
    return _barButtonItem.title;
}

- (void)setImage:(UIImage *)image {
    _barButtonItem.image = image;
}

- (UIImage *)image {
    return _barButtonItem.image;
}

#pragma mark - IFIOCProxy

- (id)unwrapValue {
    return _barButtonItem;
}

#pragma mark - IFIOCObjectAware

- (void)notifyIOCObject:(id)object propertyName:(NSString *)propertyName {
    // If the button has an action specified and the parent object is an action proxy,
    // then register the buttons action with the proxy and target the proxy when the
    // button is tapped.
    if (_action && [object conformsToProtocol:@protocol(IFActionProxy)]) {
        id<IFActionProxy> actionProxy = (id<IFActionProxy>)object;
        [actionProxy registerAction:_action forObject:_barButtonItem];
        _barButtonItem.target = actionProxy;
        _barButtonItem.action = @selector(postActionForObject:);
    }
}

#pragma mark - Class loading

+ (void)load {
    [IFContainer registerConfigurationProxyClass:self forClassName:@"UIBarButtonItem"];
}

@end
