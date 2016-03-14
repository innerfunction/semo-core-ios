//
//  IFIOCNamedDependencyPlaceholder.h
//  SemoCore
//
//  Created by Julian Goacher on 14/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFTypeInfo.h"

// TODO: There are a number or problems/shortcomings with this circular dependency solution:
// 1. It doesn't work for direct mappings in collections, e.g. { "xxx": "@named:yyy" }. The container
//    configuration cycle could be extended to support this use case, but then the approach probably
//    wouldn't work on Android due to the stricter typing (i.e. on a generically typed collection,
//    although because of type erasure, it might work...)
// 2. Not sure if the approach works for new: and make: URI schemes, due to different configuration
//    cycle. This needs testing.

/**
 * A placeholder value used to represent a deferred named value.
 * Deferred names happen when circular dependencies are detected. In such cases, the named
 * value can't be resolved till after its configuration is complete. This placeholder allows
 * the details of the named dependency to be recorded so that it can be resolved after the
 * configuration cycle has completed.
 */
@interface IFIOCPendingNamed : NSObject

- (id)initWithNamed:(NSString *)named;

@property (nonatomic, strong) NSString *named;
@property (nonatomic, strong) NSString *propName;
@property (nonatomic, strong) IFPropertyInfo *propInfo;
@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSString *referencePath;

- (id)resolveValue:(id)value;

@end
