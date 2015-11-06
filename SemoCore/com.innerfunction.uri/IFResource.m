//
//  IFURIResource.m
//  EventPacComponents
//
//  Created by Julian Goacher on 17/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFResource.h"
#import "IFCompoundURI.h"
#import "IFTypeConversions.h"
#import "IFLogging.h"

// Standard URI resource. Recognizes NSString, NSNumber and NSData resource types
// and resolves different representations appropriately.
@implementation IFResource

@synthesize uriSchemeContext, uriHandler;

- (id)initWithData:(id)data uri:(IFCompoundURI *)uri parent:(id<IFResourceContext>)parent {
    self = [super init];
    if (self) {
        self.data = data;
        self.uri = uri;
        self.uriSchemeContext = [[NSMutableDictionary alloc] initWithDictionary:parent.uriSchemeContext];
        // Set the scheme context for this resource. Copies each uri by scheme into the context, before
        // adding the resource's uri by scheme.
        for (id key in [uri.parameters allKeys]) {
            IFCompoundURI *puri = [uri.parameters valueForKey:key];
            [self.uriSchemeContext setValue:puri forKey:puri.scheme];
        }
        [self.uriSchemeContext setValue:uri forKey:uri.scheme];
        self.uriHandler = parent.uriHandler;
    }
    return self;
}

#pragma mark - representation methods

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
    return [self dereference:self.uri];
}

#pragma mark - NSObject overrides

- (NSString *)description {
    return [self asString];
}

- (NSUInteger)hash {
    return self.uri ? [self.uri hash] : [super hash];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[IFResource class]] && [self.uri isEqual:((IFResource *)object).uri];
}

#pragma mark - URIResolver protocol

- (IFResource *)dereference:(id)uri {
    return [self dereference:uri context:self];
}

- (IFResource *)dereference:(id)uri context:(id<IFResourceContext>)context {
    return [self.uriHandler dereference:uri context:context];
}

- (id)dereferenceToValue:(id)uri {
    return [self dereferenceToValue:uri context:self];
}

- (id)dereferenceToValue:(id)uri context:(id<IFResourceContext>)context {
    return [self.uriHandler dereferenceToValue:uri context:context];
}

@end