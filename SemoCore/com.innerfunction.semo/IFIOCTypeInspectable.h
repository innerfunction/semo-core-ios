//
//  IFIOCTypeDiscovery.h
//  SemoCore
//
//  Created by Julian Goacher on 23/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFIOCTypeInspectable <NSObject>

/**
 * Return the expected class for members of the named property collection.
 * This protocol is designed as an objective c replacement for type generics in java.
 * Use of this protocol allows a container to infer collection member types, instead
 * of members having to declare a semo:type in their configuration.
 */
- (__unsafe_unretained Class)memberClassForCollection:(NSString *)propertyName;

@end
