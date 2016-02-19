//
//  IFActionDispatcher.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFActionDispatcher <NSObject>

/** Initiate an action by dispatching a URI. Return YES if the action can be performed. */
- (BOOL)dispatchURI:(NSString *)uri;

@end
