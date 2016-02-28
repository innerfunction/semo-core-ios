//
//  IFMessageHandler.h
//  SemoCore
//
//  Created by Julian Goacher on 28/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFMessage.h"

/** Protocol for handling messages addressed to an object. */
@protocol IFMessageHandler <NSObject>

- (BOOL)handleMessage:(IFMessage *)message sender:(id)sender;

@end
