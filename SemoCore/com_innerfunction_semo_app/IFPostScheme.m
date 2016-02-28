//
//  IFPostScheme.m
//  SemoCore
//
//  Created by Julian Goacher on 25/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFPostScheme.h"
#import "IFMessage.h"

@implementation IFPostScheme

- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference {
    return uri;
}

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params {
    IFMessage *message = [[IFMessage alloc] initWithTarget:uri.fragment
                                                      name:uri.name
                                                parameters:params];
    return message;
}


@end
