//
//  Animal.h
//  SemoCore
//
//  Created by Julian Goacher on 25/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "Thing.h"
#import "Fruit.h"

@interface Animal : Thing

@property (nonatomic, strong) Fruit *likes;

@end
