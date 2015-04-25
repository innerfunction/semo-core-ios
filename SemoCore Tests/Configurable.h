//
//  Configurable.h
//  SemoCore
//
//  Created by Julian Goacher on 25/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFConfigurable.h"

@interface Configurable : NSObject <IFConfigurable>

@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) BOOL configured;

@end
