//
//  IFIOCConfigurable.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IFContainer, IFConfiguration;

/**
 * Protocol allowing IOC configurable objects to detect when configuration is taking place.
 */
@protocol IFIOCConfigurable <NSObject>

/** Called immediately before the object is configured by calls to its properties. */
- (void)beforeConfiguration:(IFConfiguration *)configuration inContainer:(IFContainer *)container;

/** Called immediately after the object is configured by calls to its properties. */
- (void)afterConfiguration:(IFConfiguration *)configuration inContainer:(IFContainer *)container;

@end
