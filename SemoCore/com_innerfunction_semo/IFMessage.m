//
//  IFMessage.m
//  SemoCore
//
//  Created by Julian Goacher on 28/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFMessage.h"

@implementation IFMessage

- (id)initWithTarget:(NSString *)target name:(NSString *)name parameters:(NSDictionary *)parameters {
    self = [super init];
    if (self) {
        _target = target;
        _targetPath = [target componentsSeparatedByString:@"/"];
        if ([_targetPath count] > 0 && [[_targetPath objectAtIndex:0] isEqualToString:@""]) {
            _targetPath = [_targetPath subarrayWithRange:NSMakeRange(1, [_targetPath count] - 1)];
        }
        _name = name;
        _parameters = parameters;
    }
    return self;
}

- (id)initWithTargetPath:(NSArray *)targetPath name:(NSString *)name parameters:(NSDictionary *)parameters {
    self = [super init];
    if (self) {
        _target = [targetPath componentsJoinedByString:@"/"];
        _targetPath = targetPath;
        _name = name;
        _parameters = parameters;
    }
    return self;
}

- (BOOL)hasEmptyTarget {
    return [_targetPath count] == 0;
}

- (BOOL)hasTarget:(NSString *)target {
    return [_target isEqualToString:target];
}

- (NSString *)targetHead {
    return [_targetPath count] > 0 ? [_targetPath firstObject] : nil;
}

- (IFMessage *)popTargetHead {
    if ([_targetPath count] > 0) {
        NSRange subpathRange = NSMakeRange(1, [_targetPath count] - 1);
        NSArray * subpath = [_targetPath subarrayWithRange:subpathRange];
        return [[IFMessage alloc] initWithTargetPath:subpath name:_name parameters:_parameters];
    }
    return nil;
}

- (BOOL)hasName:(NSString *)name {
    return [_name isEqualToString:name];
}

- (id)parameterValue:(NSString *)name {
    return [_parameters valueForKey:name];
}

@end
