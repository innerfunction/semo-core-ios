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

- (IFResource *)dereference:(IFCompoundURI *)uri parameters:(NSDictionary*)params parent:(IFResource *)parent {
    NSString *value = uri.name;
    if ([params count] > 0) {
        // The URI name is treated as a string template to be populated with the parameter values.
        NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
        for (NSString *name in [params keyEnumerator]) {
            [_params setValue:[(IFResource *)[params objectForKey:name] asString] forKey:name];
        }
        value = [IFStringTemplate render:value context:_params];
    }
    return [[IFResource alloc] initWithData:value uri:uri parent:parent];
}

@end
