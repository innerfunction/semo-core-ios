//
//  IFNavigationViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFMessageHandler.h"

@interface IFNavigationViewController : UINavigationController <IFMessageHandler>

/** The first view in the navigation stack. */
@property (nonatomic, strong) UIViewController *rootView;

@end
