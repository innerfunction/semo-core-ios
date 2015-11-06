//
//  IFAppContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 23/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFContainer.h"
#import "IFTarget.h"
#import "IFDefaultTargetContainerBehaviour.h"
#import "IFStandardURIHandler.h"
#import "IFLocals.h"

#define ForceResetDefaultSettings   (NO)
#define Platform                    (@"ios")
#define IOSVersion                  ([[UIDevice currentDevice] systemVersion])

@interface IFAppContainer : IFContainer <IFTarget, IFResourceContext> {
    IFStandardURIHandler *uriHandler;
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

/**
 * Utility method to load configuration from a standard location and bind to an app window.
 * Assumes app configuration is in a file named config.json.
 * Binds the container's root view to the windows rootViewController.
 * Returns the app container configured with the files contents.
 */
+ (IFAppContainer *)bindToWindow:(UIWindow *)window;

@end
