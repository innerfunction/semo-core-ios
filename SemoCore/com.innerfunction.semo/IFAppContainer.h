//
//  IFAppContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 23/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFContainer.h"
#import "IFURIResolver.h"
#import "IFLocals.h"

@interface IFAppContainer : IFContainer {
    IFStandardURIResolver *resolver;
    NSMutableDictionary *globals;
    IFLocals *locals;
}

- (void)loadConfiguration:(id)configSource;

+ (IFAppContainer *)getAppContainer;

@end