//
//  IFConfiguration.h
//  EventPacComponents
//
//  Created by Julian Goacher on 07/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFResource.h"
#import "IFJSONData.h"
#import "IFValues.h"

@protocol IFConfigurationRoot <NSObject>

- (id)getValue:(NSString *)name asRepresentation:(NSString *)representation;

@end

@class IFConfiguration;

@interface IFConfigurationPropertyHandler : IFJSONPropertyHandler {
    IFConfiguration *parent;
}

- (id)initWithConfiguration:(IFConfiguration *)_parent;

@end

// A class for reading component configurations.
// Intended use is for accessing configuration values read from a JSON file.
// The class is a thin wrapper around an IFValues instance.
@interface IFConfiguration : NSObject <IFValues, IFConfigurationRoot> {
    IFConfigurationPropertyHandler *propertyHandler;
}

@property (nonatomic, strong) id data;
@property (nonatomic, strong) id<IFConfigurationRoot> root;
@property (nonatomic, strong) NSDictionary *context;
@property (nonatomic, strong) id<IFURIHandler> uriHandler;

// Initialize the configuration with the specified data.
- (id)initWithData:(id)data;
// Initialize the configuration with the specified data and parent configuraiton.
- (id)initWithData:(id)data parent:(IFConfiguration *)parent;
// Initialize the configuration with the specified data and resource.
- (id)initWithData:(id)data uriHandler:(id<IFURIHandler>)uriHandler;
// Initialize the configuration by reading JSON from the specified resource.
- (id)initWithResource:(IFResource *)resource;
// Initialize the configuration using the specified data and the specified base resource.
- (id)initWithResource:(IFResource *)resource parent:(IFConfiguration *)parent;

// Return the name property as the specified representation.
- (id)getValue:(NSString *)key asRepresentation:(NSString*)representation;

// Return the named property as a URI resource.
//- (IFResource *)getValueAsResource:(NSString *)name;

// Return the named property as typed values.
- (IFConfiguration *)getValueAsConfiguration:(NSString *)name;
- (IFConfiguration *)getValueAsConfiguration:(NSString *)name defaultValue:(IFConfiguration *)defaultValue;

// Return the named property as a list of configurations.
- (NSArray *)getValueAsConfigurationList:(NSString *)name;

// Return the named property as a map (i.e. dictionary) of configuration objects.
// This assumes that the named property has an object value in the underlying JSON. The value of each property
// on this object should in turn be capable of resolving to a configuration object.
- (NSDictionary *)getValueAsConfigurationMap:(NSString *)name;

// Merge this values object with the provided argument and return the result.
// Values in the argument are copied over the current values object.
- (IFConfiguration *)mergeConfiguration:(IFConfiguration *)otherConfig;

// Extend this configuration with the specified set of parameters.
- (IFConfiguration *)extendWithParameters:(NSDictionary *)params;

// Normalize this configuration by flattening "config" properties and resolving "extends" properties.
- (IFConfiguration *)normalize;

// Flatten the configuration by merging its "config" property (if any) into the top level properties.
- (IFConfiguration *)flatten;

// Return a copy of the current configuration with the specified top-level keys removed.
- (IFConfiguration *)configurationWithKeysExcluded:(NSArray *)excludedKeys;

+ (IFConfiguration *)emptyConfiguration;

@end
