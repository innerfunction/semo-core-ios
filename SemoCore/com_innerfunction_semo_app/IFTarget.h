//
//  IFActionTarget.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFDoScheme.h"

/** Protocol for objects which can act as action targets. */
@protocol IFTarget <NSObject>

- (void)doAction:(IFDoAction *)action;

@end
