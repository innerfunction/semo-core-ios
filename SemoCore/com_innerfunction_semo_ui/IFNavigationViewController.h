//
//  IFNavigationViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFMessageHandler.h"

@interface IFNavigationViewController : UINavigationController <IFMessageHandler> {
    UIPanGestureRecognizer *_panGestureRecognizer;
}

/** The first view in the navigation stack. */
@property (nonatomic, strong) UIViewController *rootView;
/** The title (navigation) bar background colour. */
@property (nonatomic, strong) UIColor *titleBarColor;
/** The title (navigation) bar text colour. */
@property (nonatomic, strong) UIColor *titleTextColor;

/**
 * Replace the back swipe gesture with some other gesture.
 * Used e.g. by the slide view controller so that the pan gesture can be used to show the slide menu.
 */
- (void)replaceBackSwipeGesture:(UIPanGestureRecognizer *)recognizer;

@end
