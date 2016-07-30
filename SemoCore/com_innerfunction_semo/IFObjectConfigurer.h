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
//  Created by Julian Goacher on 06/04/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFConfiguration.h"
#import "IFTypeInfo.h"

@class IFContainer;

/**
 * A class responsible for configuring an object. Processes the object's configuration
 * by resolving property values and injecting them into the object.
 */
@interface IFObjectConfigurer : NSObject {
    /// The object container.
    IFContainer *_container;
    /// The object's property type info.
    IFTypeInfo *_typeInfo;
    /// If the object being configured is a collection (i.e. a dictionary or array) then
    /// this var contains the type hint for its members.
    IFPropertyInfo *_collectionMemberTypeInfo;
    /// The key-path to the object's configuration.
    NSString *_keyPath;
    /// A flag indicating whether the object being configured is a collection.
    BOOL _isCollection;
}

/// The object being configured.
@property (nonatomic, strong) id object;

/**
 * Initialize the configurer with the object to configure.
 * @param object    The object being configured.
 * @param container The object container.
 * @param keyPath   The key-path to the object's configuration.
 */
- (id)initWithObject:(id)object inContainer:(IFContainer *)container keyPath:(NSString *)keyPath;
/**
 * Initialize a container configurer.
 * A container is considered a collection (i.e. of named objects) with a default collection
 * member type of 'id'.
 * @param container The container to be configured.
 */
-(id)initWithContainer:(IFContainer *)container;
/// Perform the object configuration.
- (void)configureWith:(IFConfiguration *)configuration;
/**
 * Build a property value from the specified object configuration.
 * @param propName      The name of the property to configure.
 * @param configuration The object configuration; should contain the property configuration.
 * @return The value the property was configured with.
 */
- (id)buildValueForProperty:(NSString *)propName withConfiguration:(IFConfiguration *)configuration;
/**
 * Inject a property value into the object.
 * @param value The value resolved from the object configuration.
 * @param name  The name of the property to inject.
 * @return The actual value injected into the property. May differ from configuration value if
 * e.g. the value was an IOCProxy.
 */
- (id)injectValue:(id)value intoProperty:(NSString *)name;

@end
