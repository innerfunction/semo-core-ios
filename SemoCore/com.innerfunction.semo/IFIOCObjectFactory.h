//
//  IFIOCObjectFactory.h
//  SemoCore
//
//  Created by Julian Goacher on 15/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFConfiguration.h"
#import "IFContainer.h"

@protocol IFIOCObjectFactory <NSObject>

- (id)buildObjectWithConfiguration:(IFConfiguration *)configuration inContainer:(IFContainer *)container identifier:(NSString *)identifier;

@end