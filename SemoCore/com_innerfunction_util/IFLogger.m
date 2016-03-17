// Copyright 2016 InnerFunction Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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