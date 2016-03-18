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
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IFContainer, IFConfiguration;

/**
 * Protocol allowing IOC configurable objects to detect when they are being configured.
 */
@protocol IFIOCConfigurable <NSObject>

/**
 * Called immediately before the object is configured via dependency injection.
 * @param configuration The object's configuration.
 * @param container     The container the object is being instantiated within.
 */
- (void)beforeConfiguration:(IFConfiguration *)configuration inContainer:(IFContainer *)container;

/**
 * Called immediately after the object is configured via dependency injection.
 * @param configuration The object's configuration.
 * @param container     The container the object is being instantiated within.
 */
- (void)afterConfiguration:(IFConfiguration *)configuration inContainer:(IFContainer *)container;

@end
