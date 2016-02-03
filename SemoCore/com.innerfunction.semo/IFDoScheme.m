//
//  IFDoSchemeHandler.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFDoScheme.h"
#import "NSString+IF.h"

@implementation IFDoAction

- (id)parameterValue:(NSString *)name {
    return [_parameters valueForKey:name];
}

@end

@implementation IFDoSchemeHandler

- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference {
    return uri;
}

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params {
    IFDoAction *action = [[IFDoAction alloc] init];
    action.name = uri.name;
    // When setting a target of the form aaa.bbb.ccc, we are only interested in
    // the last component of the address, i.e. ccc.
    NSArray *targetComponents = [uri.fragment split:@"\\."];
    action.target = [targetComponents lastObject];
    action.parameters = params;
    return action;
}

@end
