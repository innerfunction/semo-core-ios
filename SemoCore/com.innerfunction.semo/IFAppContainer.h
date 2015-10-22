//
//  IFAppContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 23/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFContainer.h"
#import "IFActionTarget.h"
#import "IFActionTargetContainerBehaviour.h"
#import "IFURIResolver.h"
#import "IFLocals.h"

#define ForceResetDefaultSettings   (NO)
#define Platform                    (@"ios")
#define IOSVersion                  ([[UIDevice currentDevice] systemVersion])

@interface IFAppContainer : IFContainer <IFActionTarget> {
    IFStandardURIResolver *resolver;
    NSMutableDictionary *globals;
    IFLocals *locals;
    IFActionTargetContainerBehaviour *rootActionTargetContainer;
}

/** Load the app configuration. */
- (void)loadConfiguration:(id)configSource;
/** Return the app's root view. */
- (UIViewController *)getRootView;

/** Return the app container singleton instance. */
+ (IFAppContainer *)getAppContainer;

@end
