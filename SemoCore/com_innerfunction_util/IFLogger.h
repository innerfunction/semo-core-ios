//
//  IFLogger.h
//  SemoCore
//
//  Created by Julian Goacher on 07/12/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFLogging.h"

@interface IFLogger : NSObject {
    NSString *_tag;
}

- (id)initWithTag:(NSString *)tag;
- (void)debug:(NSString *)message, ...;
- (void)info:(NSString *)message, ...;
- (void)warn:(NSString *)message, ...;
- (void)error:(NSString *)message, ...;

@end