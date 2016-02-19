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

- (id)initWithData:(id)data uri:(IFCompoundURI *)uri {
    self = [super init];
    if (self) {
        self.data = data;
        self.uri = uri;
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
    return (IFResource *)[self.uriHandler dereference:self.uri];
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

@end