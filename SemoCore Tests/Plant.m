//
//  Plant.m
//  SemoCore
//
//  Created by Julian Goacher on 25/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "Plant.h"

@implementation Plant

- (__unsafe_unretained Class)memberClassForCollection:(NSString *)propertyName {
    if ([@"contains" isEqualToString:propertyName]) {
        return [Thing class];
    }
    return nil;
}

@end
