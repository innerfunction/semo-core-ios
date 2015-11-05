//
//  IFURIResource.m
//  EventPacComponents
//
//  Created by Julian Goacher on 17/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFResource.h"
#import "IFURIResolver.h"
#import "IFCompoundURI.h"
#import "IFTypeConversions.h"
#import "IFLogging.h"

// Standard URI resource. Recognizes NSString, NSNumber and NSData resource types
// and resolves different representations appropriately.
@implementation IFResource

- (id)init {
    self = [super init];
    if (self) {
        self.schemeContext = [NSDictionary dictionary];
    }
    return self;
}

- (id)initWithData:(id)data {
    self = [super init];
    if (self) {
        self.data = data;
        self.schemeContext = [NSDictionary dictionary];
    }
    return self;
}

- (id)initWithData:(id)data uri:(IFCompoundURI *)uri parent:(IFResource *)parent {
    self = [self initWithData:data];
    if (self) {
        self.uri = uri;
        self.schemeContext = [[NSMutableDictionary alloc] initWithDictionary:parent.schemeContext];
        // Set the scheme context for this resource. Copies each uri by scheme into the context, before
        // adding the resource's uri by scheme.
        for (id key in [uri.parameters allKeys]) {
            IFCompoundURI *puri = [uri.parameters valueForKey:key];
            [self.schemeContext setValue:puri forKey:puri.scheme];
        }
        [self.schemeContext setValue:uri forKey:uri.scheme];
        self.resolver = parent.resolver;
    }
    return self;
}

- (BOOL)asBoolean {
    return [IFTypeConversions asBoolean:[self asDefault]];
}

- (id)asDefault {
    return _data;
}

- (UIImage *)asImage {
    return [IFTypeConversions asImage:[self asDefault]];
}

// Access the resource's JSON representation.
// Returns the string representation parsed as a JSON string.
- (id)asJSONData {
    return [IFTypeConversions asJSONData:[self asDefault]];
}

- (NSNumber *)asNumber {
    return [IFTypeConversions asNumber:[self asDefault]];
}

// Access the resource's string representation.
- (NSString *)asString {
    return [IFTypeConversions asString:[self asDefault]];
}

- (NSData *)asData {
    return [IFTypeConversions asData:[self asDefault]];
}

- (NSURL *)asURL {
    return [IFTypeConversions asURL:[self asDefault]];
}

- (id)asRepresentation:(NSString *)representation {
    return [IFTypeConversions value:[self asDefault] asRepresentation:representation];
}

- (NSURL *)externalURL {
    return nil;
}

- (IFResource *)refresh {
    return [self derefToResource:self.uri];
}

- (IFResource *)derefStringToResource:(NSString *)suri {
    return [self derefStringToResource:suri context:self];
}

- (IFResource *)derefStringToResource:(NSString *)suri context:(IFResource *)context {
    IFResource *result = nil;
    NSError *error = nil;
    IFCompoundURI *curi = [IFCompoundURI parse:suri error:&error];
    if (error) {
        DDLogCError(@"IFResource: Parsing URI %@ (%@)", suri, [error description]);
    }
    else {
        result = [self derefToResource:curi context:context];
    }
    return result;
}

- (IFResource *)derefToResource:(IFCompoundURI *)uri {
    return [self derefToResource:uri context:self];
}

- (IFResource *)derefToResource:(IFCompoundURI *)uri context:(IFResource *)context {
    return [self.resolver derefToResource:uri context:context];
}

- (id)dereference:(IFCompoundURI *)curi {
    return [self dereference:curi context:self];
}

- (id)dereference:(IFCompoundURI *)curi context:(IFResource *)context {
    return [self.resolver dereference:curi context:context];
}

- (NSString *)description {
    return [self asString];
}

- (NSUInteger)hash {
    return self.uri ? [self.uri hash] : [super hash];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[IFResource class]] && [self.uri isEqual:((IFResource *)object).uri];
}

@end