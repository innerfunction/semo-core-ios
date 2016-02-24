//
//  IFLogger.m
//  SemoCore
//
//  Created by Julian Goacher on 07/12/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFLogger.h"

@implementation IFLogger

- (id)initWithTag:(NSString *)tag {
    self = [super init];
    if (self) {
        _tag = tag;
    }
    return self;
}

- (void)debug:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    NSString *msg = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);
    //DDLogCVerbose(@"%@: %@", _tag, msg);
    NSLog(@"%@: %@", _tag, msg);
}

- (void)info:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    NSString *msg = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);
    //DDLogInfo(@"%@: %@", _tag, msg);
    NSLog(@"%@: %@", _tag, msg);
}

- (void)warn:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    NSString *msg = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);
    //DDLogWarn(@"%@: %@", _tag, msg);
    NSLog(@"%@: %@", _tag, msg);
}

- (void)error:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    NSString *msg = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);
    //DDLogError(@"%@: %@", _tag, msg);
    NSLog(@"%@: %@", _tag, msg);
}

@end