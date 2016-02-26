//
//  IFPostScheme.m
//  SemoCore
//
//  Created by Julian Goacher on 25/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFPostScheme.h"

@implementation IFPostAction

- (id)initWithTarget:(NSString *)target message:(NSString *)message parameters:(NSDictionary *)parameters {
    self = [super init];
    if (self) {
        _absTarget = [target hasPrefix:@"/"];
        _targetPath = [target componentsSeparatedByString:@"/"];
        _message = message;
        _parameters = parameters;
    }
    return self;
}

- (id)initWithTargetPath:(NSArray *)targetPath message:(NSString *)message parameters:(NSDictionary *)parameters {
    self = [super init];
    if (self) {
        _absTarget = NO;
        _targetPath = targetPath;
        _message = message;
        _parameters = parameters;
    }
    return self;
}

- (BOOL)hasAbsoluteTarget {
    return _absTarget;
}

- (NSString *)targetHead {
    return [_targetPath count] > 0 ? [_targetPath firstObject] : nil;
}

- (IFPostAction *)popTargetHead {
    if ([_targetPath count] > 0) {
        NSRange subpathRange = NSMakeRange(1, [_targetPath count] - 1);
        NSArray * subpath = [_targetPath subarrayWithRange:subpathRange];
        return [[IFPostAction alloc] initWithTargetPath:subpath message:_message parameters:_parameters];
    }
    return nil;
}

- (id)parameterValue:(NSString *)name {
    return [_parameters valueForKey:name];
}

@end

@implementation IFPostScheme

- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference {
    return uri;
}

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params {
    IFPostAction *action = [[IFPostAction alloc] initWithTarget:uri.name
                                                        message:uri.fragment
                                                     parameters:uri.parameters];
    return action;
}


@end
