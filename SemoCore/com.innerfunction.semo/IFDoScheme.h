//
//  IFDoSchemeHandler.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFResource.h"

/** An object describing an action generated by a do: URI. */
@interface IFDoAction : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *target;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, assign) BOOL cancelled;

- (id)parameterValue:(NSString *)name;

@end

/**
 * Handler for the do: scheme.
 * Allows actions to be instantiated from a URI.
 */
@interface IFDoSchemeHandler : NSObject <IFSchemeHandler>

@end
