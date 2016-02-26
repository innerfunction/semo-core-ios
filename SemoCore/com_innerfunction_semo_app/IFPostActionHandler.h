//
//  IFPostMessageHandler.h
//  SemoCore
//
//  Created by Julian Goacher on 26/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFPostScheme.h"

@protocol IFPostActionHandler <NSObject>

- (BOOL)handlePostAction:(IFPostAction *)postAction sender:(id)sender;

@end
