//
//  IFStringSchemeHandler.m
//  EventPacComponents
//
//  Created by Julian Goacher on 13/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFStringSchemeHandler.h"
#import "IFStringTemplate.h"

// Scheme handler for resolving strings. The string always corresponds to the URI's
// scheme specific part.
@implementation IFStringSchemeHandler

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary*)params {
    NSString *value = uri.name;
    if ([params count] > 0) {
        // The URI name is treated as a string template to be populated with the parameter values.
        value = [IFStringTemplate render:value context:params];
    }
    return [value stringByRemovingPercentEncoding];
}

@end
