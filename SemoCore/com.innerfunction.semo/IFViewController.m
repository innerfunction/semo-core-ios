//
//  IFViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 11/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFViewController.h"

@implementation IFViewController

- (void)viewWillAppear:(BOOL)animated {
    if (_hideTitleBar) {
        self.navigationController.navigationBarHidden = YES;
    }
    [super viewWillAppear:animated];
}

@end
