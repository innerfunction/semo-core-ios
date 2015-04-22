//
//  IFConfiguredLocals.m
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFConfiguredLocals.h"

@implementation IFConfiguredLocals

- (id)initWithPrefix:(NSString *)_prefix configuration:(IFConfiguration *)_configuration {
    self = [super initWithPrefix:_prefix];
    if (self) {
        configuration = _configuration;
    }
    return self;
}

- (NSString *)getStringForName:(NSString *)name defaultValue:(NSString *)defaultValue {
    NSString *configValue = [configuration getValueAsString:name];
    return [super getStringForName:name defaultValue:configValue];
}

- (NSInteger)getIntegerForName:(NSString *)name defaultValue:(NSInteger)defaultValue {
    NSInteger configValue = [[configuration getValueAsNumber:name] integerValue];
    return [super getIntegerForName:name defaultValue:configValue];
}

- (BOOL)getBooleanForName:(NSString *)name defaultValue:(BOOL)defaultValue {
    BOOL configValue = [configuration getValueAsBoolean:name];
    return [super getBooleanForName:name defaultValue:configValue];
}

@end
