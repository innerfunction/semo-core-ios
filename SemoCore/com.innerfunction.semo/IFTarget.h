//
//  IFActionTarget.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFDoScheme.h"

@protocol IFTarget <NSObject>

- (void)doAction:(IFDoAction *)action;

@end
