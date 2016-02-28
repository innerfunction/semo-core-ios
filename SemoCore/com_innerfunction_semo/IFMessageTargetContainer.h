//
//  IFPostActionTargetContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 26/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFMessage.h"

/** Protocol for dispatching messages to named targets. */
@protocol IFMessageTargetContainer <NSObject>

- (BOOL)dispatchMessage:(IFMessage *)message sender:(id)sender;

@end
