//
//  IFViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 11/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IFViewController;

typedef void (^IFViewControllerEvent)(IFViewController *);

@interface IFViewController : UIViewController

@property (nonatomic, assign) BOOL hideTitleBar;
@property (nonatomic, strong) NSString *backButtonTitle;
@property (nonatomic, copy) IFViewControllerEvent onShow;

@end
