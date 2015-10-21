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

//@synthesize data, resolver, uri, schemeContext;

- (id)init {
    self = [super init];
    if (self) {
        self.schemeContext = [NSDictionary dictionary];
    }
    return self;
}

- (id)initWithData:(id)_data {
    self = [super init];
    if (self) {
        self.data = _data;
        self.schemeContext = [NSDictionary dictionary];
    }
    return self;
}

- (id)initWithData:(id)_data uri:(IFCompoundURI *)_uri parent:(IFResource *)parent {
    self = [self initWithData:_data];
    if (self) {
        self.uri = _uri;
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
    return data;
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
    return [self dereference:self.uri];
}

- (IFResource *)dereferenceString:(NSString *)suri {
    return [self dereferenceString:suri context:self];
}

- (IFResource *)dereferenceString:(NSString *)suri context:(IFResource *)context {
    IFResource *result = nil;
    NSError *error = nil;
    IFCompoundURI *curi = [IFCompoundURI parse:suri error:&error];
    if (error) {
        DDLogCError(@"IFResource: Parsing URI %@ (%@)", suri, [error description]);
    }
    else {
        result = [self dereference:curi context:context];
    }
    return result;
}

- (IFResource *)dereference:(IFCompoundURI *)curi {
    return [self dereference:curi context:self];
}

- (IFResource *)dereference:(IFCompoundURI *)curi context:(IFResource *)context {
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