//
//  IFIOCConfigurable.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFIOCConfigurable <NSObject>

- (void)beforeConfigure;

- (void)afterConfigure;

@end
