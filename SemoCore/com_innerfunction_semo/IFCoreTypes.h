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
//  Created by Julian Goacher on 28/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A set of standard core type mappings.
 * Maps the following standard type names:
 * - *EmptyView*      => IFViewController
 * - *NavigationView* => IFNavigationViewController
 * - *SlideView*      => IFSlideViewController
 * - *WebView*        => IFWebViewController
 * - *ListView*       => IFListViewController
 */
@interface IFCoreTypes : NSObject

/// The core types.
+ (NSDictionary *)types;

@end
