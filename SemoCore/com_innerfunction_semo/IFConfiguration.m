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
//  Created by Julian Goacher on 07/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFConfiguration.h"
#import "IFRegExp.h"
#import "IFStringTemplate.h"
#import "IFTypeConversions.h"
#import "NSDictionary+IF.h"
#import "UIColor+IF.h"
#import "IFLogging.h"

@interface IFConfiguration()

- (id)initWithData:(id)data parent:(IFConfiguration *)parent;
- (id)initWithData:(id)data resource:(IFResource *)resource;
- (id)initWithConfiguration:(IFConfiguration *)config parent:(IFConfiguration *)parent;
- (void)initializeContext;

@end

@implementation IFConfigurationPropertyHandler

- (id)initWithConfiguration:(IFConfiguration *)_parent {
    self = [super init];
    if (self) {
        parent = _parent;
    }
    return self;
}

- (id)resolveName:(NSString *)name on:(id)value representation:(NSString *)representation {
    if ([value isKindOfClass:[IFResource class]]) {
        value = [(IFResource *)value asJSONData];
    }
    return [super resolveName:name on:value representation:representation];
}

- (id)modifyValue:(id)value forName:(id)name representation:(NSString *)representation {
    if ([value isKindOfClass:[NSString class]]) {
        // Interpret the string value.
        NSString* stringValue = (NSString *)value;
        // First, attempt resolving any context references. If these in turn resolve to a
        // $ or # prefixed value, then they will be resolved in the following code.
        if ([stringValue hasPrefix:@"$"]) {
            value = [parent.context objectForKey:stringValue];
            if ([value isKindOfClass:[NSString class]]) {
                stringValue = (NSString *)value;
            }
            else {
                return value;
            }
        }
        // Evaluate any string beginning with ? as a string template.
        if ([stringValue hasPrefix:@"?"]) {
            stringValue = [stringValue substringFromIndex:1];
            stringValue = [IFStringTemplate render:(NSString*)stringValue context:parent.context];
        }
        // Any string values starting with a '@' are potentially internal URI references.
        // Normalize to URI references with a default representation qualifier.
        // If a dispatcher is also set on this configuration object then attempt to resolve
        // the URI and return its value instead.
        if ([stringValue hasPrefix:@"@"]) {
            NSString* uri = [stringValue substringFromIndex:1];
            value = [parent.uriHandler dereference:uri];
        }
        // Any string values starting with a '#' are potential path references to other
        // properties in the same configuration. Attempt to resolve them against the configuration
        // root; if they don't resolve then return the original value.
        else if ([stringValue hasPrefix:@"#"]) {
            value = [parent.root getValue:[stringValue substringFromIndex:1] asRepresentation:representation];
            if (value == nil) {
                value = stringValue;
            }
        }
        else if ([stringValue hasPrefix:@"`"]) {
            value = [stringValue substringFromIndex:1];
        }
        else if (stringValue) {
            value = stringValue;
        }
    }
    return value;
}

@end

@implementation IFConfiguration

- (id)init {
    // Initialize with an empty dictionary.
    self = [super init];
    self.data = [NSDictionary dictionary];
    [self initializeContext];
    return self;
}

- (id)initWithData:(id)data {
    return [self initWithData:data parent:[IFConfiguration emptyConfiguration]];
}

- (id)initWithData:(id)data uriHandler:(id<IFURIHandler>)uriHandler {
    self = [self initWithData:data];
    self.uriHandler = uriHandler;
    return self;
}

- (id)initWithData:(id)data parent:(IFConfiguration *)parent {
    self = [super init];
    if (self) {
        if ([data isKindOfClass:[NSString class]]) {
            self.data = [IFTypeConversions asJSONData:data];
        }
        else {
            self.data = data;
        }
        self.root = parent.root;
        self.context = parent.context;
        self.uriHandler = parent.uriHandler;
        [self initializeContext];
        propertyHandler = [[IFConfigurationPropertyHandler alloc] initWithConfiguration:self];
    }
    return self;
}

- (id)initWithConfiguration:(IFConfiguration *)config parent:(IFConfiguration *)parent {
    self = [super init];
    if (self) {
        NSDictionary *data = [[NSMutableDictionary alloc] init];
        if ([config.data isKindOfClass:[NSDictionary class]]) {
            data = [data extendWith:(NSDictionary *)config.data];
        }
        if ([parent.data isKindOfClass:[NSDictionary class]]) {
            data = [data extendWith:(NSDictionary *)parent.data];
        }
        self.data = data;
        self.root = parent.root;
        self.context = [config.context extendWith:parent.context];
        self.uriHandler = parent.uriHandler;
        [self initializeContext];
        propertyHandler = [[IFConfigurationPropertyHandler alloc] initWithConfiguration:self];
    }
    return self;
}

- (id)initWithResource:(IFResource *)resource {
    return [self initWithData:[resource asJSONData] resource:resource];
}

- (id)initWithData:(id)data resource:(IFResource *)resource {
    if (self = [super init]) {
        self.data = data;
        self.root = self;
        self.uriHandler = resource.uriHandler;
        [self initializeContext];
        propertyHandler = [[IFConfigurationPropertyHandler alloc] initWithConfiguration:self];
    }
    return self;
}

- (id)initWithResource:(IFResource *)resource parent:(IFConfiguration *)parent {
    self = [super init];
    if (self) {
        self.data = [resource asJSONData];
        self.root = self;
        self.context = parent.context;
        self.uriHandler = parent.uriHandler;
        [self initializeContext];
        propertyHandler = [[IFConfigurationPropertyHandler alloc] initWithConfiguration:self];
    }
    return self;
}

- (void)initializeContext {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    // Search the configuration data for any parameter values, filter parameter values out of main data values.
    for (NSString *name in [_data allKeys]) {
        if ([name hasPrefix:@"$"]) {
            [params setObject:[_data objectForKey:name] forKey:name];
        }
        else {
            [values setObject:[_data objectForKey:name] forKey:name];
        }
    }
    // Initialize/modify the context with parameter values, if any.
    if ([params count]) {
        if (self.context) {
            self.context = [self.context extendWith:params];
        }
        else {
            self.context = params;
        }
        self.data = values;
    }
    else if (!self.context) {
        self.context = [NSDictionary dictionary];
    }
}

- (id)getValue:(NSString*)KeyPath asRepresentation:(NSString *)representation {
    
    id value = [IFJSONData resolvePath:KeyPath onData:_data handler:propertyHandler representation:representation];
    
    // Perform type conversions according to the requested representation.
    // These are pretty basic:
    // * Bare values are return unchanged
    // * If the requested representation is 'resource', and the value isn't already a result, then
    //   construct a new resource with the current value. Note that the new resource URI is the same
    //   as this configuration's base resource.
    // Otherwise:
    // * A Resource can be converted to anything its getRepresentation method supports;
    // * A String can be converted to a URL and is valid JSON data;
    // * A Number can be converted to a String and is valid JSON data;
    // * Anything else is only valid JSON data.
    if ([@"bare" isEqualToString:representation]) {
    }
    /*
    else if ([@"resource" isEqualToString:representation]) {
        if ( value && ![value isKindOfClass:[IFResource class]]) {
            IFCompoundURI *uri = [resource.uri copyOfWithFragment:name];
            value = [[IFResource alloc] initWithData:value uri:uri parent:resource];
        }
    }
    */
    else if ([@"configuration" isEqualToString:representation]) {
        if (![value isKindOfClass:[IFConfiguration class]]) {
            // If value isn't already a configuration, but is a dictionary then construct a new config using the values in that dictionary...
            if ([value isKindOfClass:[NSDictionary class]]) {
                value = [[IFConfiguration alloc] initWithData:value parent:self];
            }
            // Else if value is a resource, then construct a new config using the resource...
            else if ([value isKindOfClass:[IFResource class]]) {
                value = [[IFConfiguration alloc] initWithResource:(IFResource *)value parent:self];
            }
            // Else the value can't be resolved to a resource, so return nil.
            else {
                value = nil;
            }
        }
    }
    else if ([value isKindOfClass:[IFResource class]]) {
        value = [(IFResource*)value asRepresentation:representation];
    }
    else if (![@"json" isEqualToString:representation]) {
        value = [IFTypeConversions value:value asRepresentation:representation];
    }
    return value;
}

- (BOOL)hasValue:(NSString *)keyPath {
    return [self getValue:keyPath asRepresentation:@"bare"] != nil;
}

- (NSString *)getValueAsString:(NSString *)keyPath {
    return [self getValueAsString:keyPath defaultValue:nil];
}

- (NSString *)getValueAsString:(NSString*)keyPath defaultValue:(NSString*)defaultValue {
    NSString* value = [self getValue:keyPath asRepresentation:@"string"];
    return value == nil || ![value isKindOfClass:[NSString class]] ? defaultValue : value;
}

- (NSString *)getValueAsLocalizedString:(NSString *)keyPath {
    NSString *value = [self getValueAsString:keyPath];
    return value == nil ? nil : NSLocalizedString(value, @"");
}

- (NSNumber *)getValueAsNumber:(NSString *)keyPath {
    return [self getValueAsNumber:keyPath defaultValue:nil];
}

- (NSNumber *)getValueAsNumber:(NSString*)keyPath defaultValue:(NSNumber*)defaultValue {
    NSNumber* value = [self getValue:keyPath asRepresentation:@"number"];
    return value == nil || ![value isKindOfClass:[NSNumber class]] ? defaultValue : value;
}

- (BOOL)getValueAsBoolean:(NSString *)keyPath {
    return [self getValueAsBoolean:keyPath defaultValue:NO];
}

- (BOOL)getValueAsBoolean:(NSString*)keyPath defaultValue:(BOOL)defaultValue {
    NSNumber* value = [self getValue:keyPath asRepresentation:@"number"];
    return value == nil ? defaultValue : [value boolValue];
}

// Resolve a date value on the cell data at the specified path.
- (NSDate *)getValueAsDate:(NSString *)keyPath {
    return [self getValueAsDate:keyPath defaultValue:nil];
}

// Resolve a date value on the cell data at the specified path, return the default value if not set.
- (NSDate *)getValueAsDate:(NSString *)keyPath defaultValue:(NSDate *)defaultValue {
    NSDate *value = [self getValue:keyPath asRepresentation:@"date"];
    return value == nil || ![value isKindOfClass:[NSDate class]] ? defaultValue : value;
}

- (UIColor *)getValueAsColor:(NSString *)keyPath {
    NSString *hexValue = [self getValueAsString:keyPath];
    return hexValue ? [UIColor colorForHex:hexValue] : nil;
}

- (UIColor *)getValueAsColor:(NSString *)keyPath defaultValue:(UIColor *)defaultValue {
    UIColor *color = [self getValueAsColor:keyPath];
    return color ? color : defaultValue;
}

- (NSURL *)getValueAsURL:(NSString *)keyPath {
    NSURL *value = [self getValue:keyPath asRepresentation:@"url"];
    return [value isKindOfClass:[NSURL class]] ? value : nil;
}

- (NSData *)getValueAsData:(NSString *)keyPath {
    NSData *value = [self getValue:keyPath asRepresentation:@"data"];
    return [value isKindOfClass:[NSData class]] ? value : nil;
}

- (UIImage *)getValueAsImage:(NSString *)keyPath {
    UIImage *value = [self getValue:keyPath asRepresentation:@"image"];
    return [value isKindOfClass:[UIImage class]] ? value : nil;
}

- (id)getValue:(NSString *)keyPath {
    return [self getValue:keyPath asRepresentation:@"bare"];
}

- (NSArray *)getValueNames {
    if ([_data respondsToSelector:@selector(allKeys)]) {
        return [_data allKeys];
    }
    return [NSArray array];
}

- (IFValueType)getValueType:(NSString *)keyPath {
    id value = [self getValue:keyPath asRepresentation:@"json"];
    if (value == nil)                           return IFValueTypeUndefined;
    // NOTE: Can't reliably detect boolean here, as boolean values are represented using NSNumber.
    if ([value isKindOfClass:[NSNumber class]]) return IFValueTypeNumber;
    if ([value isKindOfClass:[NSString class]]) return IFValueTypeString;
    if ([value isKindOfClass:[NSArray class]])  return IFValueTypeList;
    if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[IFConfiguration class]])
                                                return IFValueTypeObject;
    return IFValueTypeOther;
}

- (IFConfiguration *)getValueAsConfiguration:(NSString *)keyPath {
    return [self getValue:keyPath asRepresentation:@"configuration"];
}

- (IFConfiguration *)getValueAsConfiguration:(NSString *)keyPath defaultValue:(IFConfiguration *)defaultValue {
    IFConfiguration *result = [self getValueAsConfiguration:keyPath];
    return result ? result : defaultValue;
}

- (NSArray *)getValueAsConfigurationList:(NSString *)keyPath {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if ([self getValueType:keyPath] == IFValueTypeList) {
        NSArray *valuesArray = (NSArray *)[self getValue:keyPath];
        if (![valuesArray isKindOfClass:[NSArray class]]) {
            valuesArray = [self getValue:keyPath asRepresentation:@"json"];
        }
        if ([valuesArray isKindOfClass:[NSArray class]]) {
            for (NSInteger i = 0; i < [valuesArray count]; i++) {
                NSString *itemKeyPath = [NSString stringWithFormat:@"%@.%ld", keyPath, (long)i];
                IFConfiguration *item = [self getValueAsConfiguration:itemKeyPath];
                [result addObject:item];
            }
        }
    }
    return result;
}

- (NSDictionary *)getValueAsConfigurationMap:(NSString *)keyPath {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    id values = [self getValue:keyPath];
    if ([values isKindOfClass:[NSDictionary class]]) {
        NSDictionary *valuesDictionary = (NSDictionary *)values;
        for (id key in [valuesDictionary allKeys]) {
            NSString *itemKeyPath = [NSString stringWithFormat:@"%@.%@", keyPath, key];
            IFConfiguration *item = [self getValueAsConfiguration:itemKeyPath];
            [result setObject:item forKey:key];
        }
    }
    return result;
}

- (IFConfiguration *)mergeConfiguration:(IFConfiguration *)otherConfig {
    // See note in Configuration.java about the parent argument below.
    return [[IFConfiguration alloc] initWithConfiguration:self parent:otherConfig];
}

- (IFConfiguration *)extendWithParameters:(NSDictionary *)params {
    IFConfiguration *result = self;
    if ([params count] > 0) {
        result = [[IFConfiguration alloc] initWithData:self.data parent:self];
        NSMutableDictionary *$params = [[NSMutableDictionary alloc] initWithCapacity:[params count]];
        for (NSString *name in [params allKeys]) {
            [$params setObject:[params objectForKey:name] forKey:[NSString stringWithFormat:@"$%@", name]];
        }
        result.context = [result.context extendWith:$params];
    }
    return result;
}

- (IFConfiguration *)flatten {
    IFConfiguration *result = self;
    // TODO: *config to be deprecated in place of mixin (- maybe; the term makes sense in some cases).
    if ([self getValueType:@"*config"] == IFValueTypeObject) {
        result = [self mergeConfiguration:[self getValueAsConfiguration:@"*config"]];
    }
    // TODO: Add support for an array of mixin objects, or support *mixins property as same.
    if ([self getValueType:@"*mixin"] == IFValueTypeObject) {
        result = [self mergeConfiguration:[self getValueAsConfiguration:@"*mixin"]];
    }
    return result;
}

- (IFConfiguration *)normalize {
    // Start by flattening this configuration (i.e. merging its "config" property into the top level).
    IFConfiguration *result = [self flatten];
    // Next, start processing the "extends" chain...
    IFConfiguration *current = result;
    // A set of previously visited parent configurations, to detect dependency loops.
    NSMutableSet *visited = [[NSMutableSet alloc] init];
    // TODO: Following seems wrong, it will work OK for a two-level extends chain, but is wrong for
    // deeper chains. Instead, the full extension hierarchy should be resolved, and then merged in
    // reverse order.
    while ([current getValueType:@"*extends"] == IFValueTypeObject) {
        current = [current getValueAsConfiguration:@"*extends"];
        if ([visited containsObject:current]) {
            // Dependency loop detected, stop extending the config.
            break;
        }
        [visited addObject:current];
        result = [[current flatten] mergeConfiguration:result];
    }
    return result;
}

- (IFConfiguration *)configurationWithKeysExcluded:(NSArray *)excludedKeys {
    NSDictionary *data = [(NSDictionary *)_data dictionaryWithKeysExcluded:excludedKeys];
    IFConfiguration *result = [[IFConfiguration alloc] initWithData:data];
    result.root = _root;
    result.context = _context;
    result.uriHandler = _uriHandler;
    return result;
}

/*
- (NSUInteger)hash {
    return self.resource ? [self.resource hash] : [super hash];
}
*/

- (BOOL)isEqual:(id)object {
    // Two configurations are equal if the have the same source resource.
    //return [object isKindOfClass:[IFConfiguration class]] && [self.resource isEqual:((IFConfiguration *)object).resource];
    return [object isKindOfClass:[IFConfiguration class]] && [_data isEqual:((IFConfiguration *)object).data];
}

static IFConfiguration *emptyConfiguaration;

+ (void)initialize {
    emptyConfiguaration = [[IFConfiguration alloc] init];
}

+ (IFConfiguration *)emptyConfiguration {
    return emptyConfiguaration;
}

@end
