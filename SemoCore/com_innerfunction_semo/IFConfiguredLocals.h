//
//  IFConfiguredLocals.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFLocals.h"
#import "IFConfiguration.h"

@interface IFConfiguredLocals : IFLocals {
    IFConfiguration *configuration;
}

- (id)initWithPrefix:(NSString *)namespacePrefix configuration:(IFConfiguration *)configuration;

@end
