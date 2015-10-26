//
//  UIViewController+Toast.m
//  SemoCore
//
//  Created by Julian Goacher on 26/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "UIViewController+Toast.h"
#import "UIView+Toast.h"

#define ToastMessageDuration    (1.0f)

@implementation UIViewController (Toast)

- (void)showToastMessage:(NSString *)message {
    message = NSLocalizedString(message, @"");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view hideToastActivity]; // Hide any currently visible toast message.
        [self.view makeToast:message duration:ToastMessageDuration position:CSToastPositionBottom];
    });
}

@end
