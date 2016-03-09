//
//  IFIOCProxyObject.m
//  SemoCore
//
//  Created by Julian Goacher on 09/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFIOCProxyObject.h"

@implementation IFIOCProxyObject

- (id)initWithValue:(id)value {
    return [super init];
}

- (id)unwrapValue {
    return nil;
}

#pragma mark - Static methods

// May of configuration proxies keyed by class name. Classes without a registered proxy get an NSNull entry.
static NSMutableDictionary *IFIOCProxyObject_proxies;

+ (void)initialize {
    IFIOCProxyObject_proxies = [NSMutableDictionary new];
}

+ (void)registerConfigurationProxyClass:(__unsafe_unretained Class)proxyClass forClassName:(NSString *)className {
    IFIOCProxyObject_proxies[className] = [NSValue valueWithNonretainedObject:proxyClass];
}

+ (NSDictionary *)registeredProxyClasses {
    NSMutableDictionary *result = IFIOCProxyObject_proxies;
    IFIOCProxyObject_proxies = nil; // Discard proxy dictionary.
    return result;
}

@end
