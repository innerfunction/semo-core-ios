//
//  IFViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 11/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFViewController.h"
#import "IFAppContainer.h"

@implementation IFViewController

@synthesize iocContainer = _iocContainer;

- (id)init {
    self = [super init];
    if (self) {
        _hideTitleBar = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = _hideTitleBar;
    [super viewWillAppear:animated];
    if (_backButtonTitle) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_backButtonTitle
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_onShow) {
        _onShow(self);
    }
}

- (void)postAction:(NSString *)action {
    // TODO: Move URI rewrite rules to here. They should be applied only once, by the action sender.
    [(IFAppContainer *)_iocContainer postAction:action sender:self];
}

@end
