//
//  IFPostMessageHandler.h
//  SemoCore
//
//  Created by Julian Goacher on 26/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IFPostAction;

@protocol IFPostActionHandler <NSObject>

- (BOOL)handlePostAction:(IFPostAction *)postAction;

@end
