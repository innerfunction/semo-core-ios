//
//  IFIOCConfigurable.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IFContainer;

@protocol IFIOCConfigurable <NSObject>

- (void)beforeConfigure:(IFContainer *)container;

- (void)afterConfigure:(IFContainer *)container;

@end
