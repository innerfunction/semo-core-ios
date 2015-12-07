//
//  IFService.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFService <NSObject>

- (void)startService;

@optional

- (void)stopService;

@end
