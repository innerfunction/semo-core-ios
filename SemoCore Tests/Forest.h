//
//  Forest.h
//  SemoCore
//
//  Created by Julian Goacher on 25/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "Thing.h"
#import "IFIOCTypeInspectable.h"

@interface Forest : Thing <IFIOCTypeInspectable>

@property (nonatomic, strong) NSDictionary *thingsInTheForest;

@end
