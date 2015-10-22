//
//  IFDoSchemeHandler.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFDoScheme.h"

@implementation IFDoAction

- (IFResource *)parameterValue:(NSString *)name {
    return (IFResource *)[_parameters valueForKey:name];
}

@end

@implementation IFDoSchemeHandler

- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference {
    return uri;
}

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params parent:(IFResource *)parent {
    IFDoAction *action = [[IFDoAction alloc] init];
    action.name = uri.name;
    action.target = uri.fragment;
    action.parameters = params;
    return action;
}

@end
