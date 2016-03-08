//
//  IFActionProxy.h
//  SemoCore
//
//  Created by Julian Goacher on 08/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocol implemented by objects which can post actions for other objects.
@protocol IFActionProxy <NSObject>

// Register an action to be posted when the specified object requests a post.
- (void)registerAction:(NSString *)action forObject:(id)object;
// Post the registered action for the specified object.
- (void)postActionForObject:(id)object;

@end
