// Copyright 2016 InnerFunction Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Julian Goacher on 11/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFIOCContainerAware.h"
#import "IFMessageReceiver.h"
#import "IFActionProxy.h"
#import "IFViewBehaviour.h"

/**
 * A configurable version of the _UIViewController_ class.
 * Implements the <IFMessageReceiver> protocol and responds to the following messages:
 * - _toast_: Display an Android style popup message. Must have a _message_ parameter.
 * - _show-image_: Display an image in a pop-over view. Must have an _image_ parameter.
 */
@interface IFViewController : UIViewController <IFIOCContainerAware, IFMessageReceiver, IFActionProxy, IFViewBehaviourController> {
    NSMutableDictionary *_actionProxyLookup;
}

/** Flag indicating whether to show or hide the title bar. */
@property (nonatomic, assign) BOOL hideTitleBar;
/** The title of the view's back button when presented within a navigation controller. */
@property (nonatomic, strong) NSString *backButtonTitle;
/** An optional left-side title bar item. */
@property (nonatomic, strong) UIBarButtonItem *leftTitleBarButton;
/** An optional right-side title bar item. */
@property (nonatomic, strong) UIBarButtonItem *rightTitleBarButton;
/**
 * The layout name. Corresponds to the name of a nib file. If specified then the view controller will load and display
 * the layout.
 */
@property (nonatomic, strong) NSString *layoutName;
/**
 * Map of named view components. Allows placeholder elements within the layout to be replaced with components
 * built from the configurations described in this map.
 */
@property (nonatomic, strong) NSDictionary *namedViews;
/** Map of named view names onto nib file view tags. */
@property (nonatomic, strong) NSDictionary *namedViewTags;

- (id)initWithView:(UIView *)view;
- (void)postMessage:(NSString *)message;

@end
