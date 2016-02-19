//
//  IFReprSchemeHandler.m
//  SemoCore
//
//  Created by Julian Goacher on 11/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFReprSchemeHandler.h"
#import "IFResource.h"
#import "IFTypeConversions.h"

@implementation IFReprSchemeHandler


- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary*)params {
    // The URI name gives the name of the required representation.
    NSString *repr = uri.name;
    // The value who's representation we want.
    id value = [params valueForKey:@"value"];
    if ([value isKindOfClass:[IFResource class]]) {
        // If the value is a URI resource then use the resource's own methods to get the representation.
        value = [value asRepresentation:repr];
    }
    else {
        // Else use standard type conversions to get the representation.
        value = [IFTypeConversions value:value asRepresentation:repr];
    }
    return value;
}

@end
