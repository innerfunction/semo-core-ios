//
//  IFViewBehaviour.h
//  SemoCore
//
//  Created by Julian Goacher on 12/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFMessageHandler.h"

// Protocol for view behaviour decorators.
@protocol IFViewBehaviour <IFMessageHandler>

@property (nonatomic, weak) UIViewController *viewController;

- (void)viewDidAppear;

@end

// Protocol for views capable of having their behaviour decorated.
@protocol IFViewBehaviourController <NSObject>

/** An array of attached view behaviours. */
@property (nonatomic, strong) NSArray *behaviours;
/** Utility property for setting a single behaviour. */
@property (nonatomic, strong) id<IFViewBehaviour> behaviour;

- (void)addBehaviour:(id<IFViewBehaviour>)behaviour;

@end