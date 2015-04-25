//
//  Forest.m
//  SemoCore
//
//  Created by Julian Goacher on 25/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "Forest.h"

@implementation Forest

- (__unsafe_unretained Class)memberClassForCollection:(NSString *)propertyName {
    if ([@"thingsInTheForest" isEqualToString:propertyName]) {
        return [Thing class];
    }
    return nil;
}

@end
