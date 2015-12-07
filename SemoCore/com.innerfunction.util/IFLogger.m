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
    message = [[NSString alloc] initWithFormat:message arguments:args];
    DDLogCVerbose(@"%@: %@", _tag, message);
    va_end(args);
}

- (void)info:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    message = [[NSString alloc] initWithFormat:message arguments:args];
    DDLogInfo(@"%@: %@", _tag, message);
    va_end(args);
}

- (void)warn:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    message = [[NSString alloc] initWithFormat:message arguments:args];
    DDLogWarn(@"%@: %@", _tag, message);
    va_end(args);
}

- (void)error:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    message = [[NSString alloc] initWithFormat:message arguments:args];
    DDLogError(@"%@: %@", _tag, message);
    va_end(args);
}

@end