//
//  IOCConfigurable.h
//  SemoCore
//
//  Created by Julian Goacher on 25/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFIOCConfigurable.h"

@interface IOCConfigurable : NSObject <IFIOCConfigurable>

@property (nonatomic, assign) BOOL beforeConfigureCalled;
@property (nonatomic, assign) BOOL afterConfigureCalled;
@property (nonatomic, strong) NSString *value;

@end
