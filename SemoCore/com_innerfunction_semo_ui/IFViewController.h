//
//  IFViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 11/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFIOCContainerAware.h"
#import "IFMessageHandler.h"
#import "IFActionProxy.h"

@class IFViewController;

typedef void (^IFViewControllerEvent)(IFViewController *);

@interface IFViewController : UIViewController <IFIOCContainerAware, IFMessageHandler, IFActionProxy> {
    NSMutableDictionary *_actionProxyLookup;
}

/** Flag indicating whether to show or hide the title bar. */
@property (nonatomic, assign) BOOL hideTitleBar;
/** The title of the view's back button when presented within a navigation controller. */
@property (nonatomic, strong) NSString *backButtonTitle;
/** Block invoked when view is displayed. */
@property (nonatomic, copy) IFViewControllerEvent onShow;
/** The layout name. Corresponds to the name of a nib file. */
@property (nonatomic, strong) NSString *layoutName;
/** Map of named view components. */
@property (nonatomic, strong) NSDictionary *namedViews;
/** Map of named view names onto nib file view tags. */
@property (nonatomic, strong) NSDictionary *namedViewTags;

- (id)initWithView:(UIView *)view;
- (void)postMessage:(NSString *)message;

@end
