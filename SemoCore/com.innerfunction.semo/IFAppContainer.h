//
//  IFAppContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 23/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFContainer.h"
#import "IFTarget.h"
#import "IFDefaultTargetContainerBehaviour.h"
#import "IFURIResolver.h"
#import "IFLocals.h"

#define ForceResetDefaultSettings   (NO)
#define Platform                    (@"ios")
#define IOSVersion                  ([[UIDevice currentDevice] systemVersion])

@interface IFAppContainer : IFContainer <IFTarget> {
    IFStandardURIResolver *resolver;
    NSMutableDictionary *globals;
    IFLocals *locals;
    IFDefaultTargetContainerBehaviour *rootTargetContainer;
}

/** Load the app configuration. */
- (void)loadConfiguration:(id)configSource;
/** Return the app's root view. */
- (UIViewController *)getRootView;

/** Return the app container singleton instance. */
+ (IFAppContainer *)getAppContainer;

@end
