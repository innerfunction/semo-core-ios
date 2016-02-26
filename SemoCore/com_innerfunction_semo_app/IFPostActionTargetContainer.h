//
//  IFPostActionTargetContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 26/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFPostActionTargetContainer <NSObject>

- (void)dispatchAction:(IFPostAction *)postAction sender:(id)sender;

@end
