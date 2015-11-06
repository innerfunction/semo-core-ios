//
//  IFURIResolver.m
//  EventPacComponents
//
//  Created by Julian Goacher on 12/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFStandardURIHandler.h"
#import "IFStringSchemeHandler.h"
#import "IFFileBasedSchemeHandler.h"
#import "IFLocalSchemeHandler.h"
#import "IFResource.h"

#define MainBundlePath  ([[NSBundle mainBundle] resourcePath])

@interface IFStandardURIHandler()

- (IFCompoundURI *)promoteToCompoundURI:(id)uri;

@end

// Internal URI resolver. The resolver is configured with a set of mappings between
// URI scheme names and scheme handlers, which it then uses to resolve compound URIs
// to URI resources.
@implementation IFStandardURIHandler

- (id)initWithResourceContext:(id<IFResourceContext>)context {
    return [self initWithMainBundlePath:MainBundlePath resourceContext:context];
}

- (id)initWithMainBundlePath:(NSString *)mainBundlePath resourceContext:(id<IFResourceContext>)context {
    self = [super init];
    if (self) {
        schemeHandlers = [[NSMutableDictionary alloc] init];
        resourceContext = context;
        // Add standard schemes.
        [schemeHandlers setValue:[[IFStringSchemeHandler alloc] init]
                          forKey:@"s"];
        // See following for info on iOS file system dirs.
        // https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/Reference/reference.html
        // http://developer.apple.com/library/ios/#documentation/FileManagement/Conceptual/FileSystemProgrammingGUide/FileSystemOverview/FileSystemOverview.html
        // TODO: app: scheme handler not resolving (in simulator anyway):
        // Resolved path: /Users/juliangoacher/Library/Application\ Support/iPhone\ Simulator/5.0/Applications/F578A85D-A358-4897-A0BE-9BE8714B50D4/Applications/
        // Actual path:   /Users/juliangoacher/Library/Application\ Support/iPhone\ Simulator/5.0/Applications/F578A85D-A358-4897-A0BE-9BE8714B50D4/EventPacComponents.app/
        [schemeHandlers setValue:[[IFFileBasedSchemeHandler alloc] initWithPath:mainBundlePath]
                          forKey:@"app"];
        [schemeHandlers setValue:[[IFFileBasedSchemeHandler alloc] initWithDirectory:NSCachesDirectory]
                          forKey:@"cache"];
        [schemeHandlers setValue:[[IFLocalSchemeHandler alloc] init]
                          forKey:@"local"];
    }
    return self;
}

// Test whether this resolver has a handler for a URI's scheme.
- (BOOL)hasHandlerForURIScheme:(NSString *)scheme {
    return [schemeHandlers valueForKey:scheme] != nil;
}

// Register a new scheme handler.
- (void)addHandler:(id<IFSchemeHandler>)handler forScheme:(NSString *)scheme {
    [schemeHandlers setValue:handler forKey:scheme];
}

// Return a list of registered URI scheme names.
- (NSArray *)getURISchemeNames {
    return [schemeHandlers allKeys];
}

// Return the URI handler for the named scheme.
- (id<IFSchemeHandler>)getHandlerForURIScheme:(NSString *)scheme {
    return [schemeHandlers valueForKey:scheme];
}

- (IFResource *)dereference:(id)uri {
    return [self dereference:uri context:resourceContext];
}

- (IFResource *)dereference:(id)uri context:(id<IFResourceContext>)context {
    IFResource *resource = nil;
    id value = [self dereferenceToValue:uri context:context];
    // Wrap bare values in a resource object.
    if (value && ![value isKindOfClass:[IFResource class]]) {
        IFCompoundURI *compUri = [self promoteToCompoundURI:uri];
        resource = [[IFResource alloc] initWithData:value uri:compUri parent:context];
    }
    else {
        resource = (IFResource *)value;
    }
    return resource;
}

- (id)dereferenceToValue:(id)uri {
    return [self dereferenceToValue:uri context:resourceContext];
}

- (id)dereferenceToValue:(id)uri context:(id<IFResourceContext>)context {
    IFCompoundURI *compUri;
    if ([uri isKindOfClass:[IFCompoundURI class]]) {
        compUri = (IFCompoundURI *)uri;
    }
    else {
        compUri = [self promoteToCompoundURI:uri];
    }
    id value = nil;
    // Resolve a handler for the URI scheme.
    id<IFSchemeHandler> schemeHandler = [schemeHandlers valueForKey:compUri.scheme];
    if (schemeHandler) {
        // Dictionary of resolved URI parameters.
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:[compUri.parameters count]];
        // Iterate over the URIs parameter values (which are also URIs) and dereference each
        // of them.
        for (NSString *name in [compUri.parameters allKeys]) {
            IFResource *value = [self dereference:[compUri.parameters valueForKey:name] context:context];
            if (value != nil) {
                [params setValue:value forKey:name];
            }
        }
        // Resolve the current URI to an absolute form (potentially).
        if ([schemeHandler respondsToSelector:@selector(resolve:against:)] && context.uriSchemeContext ) {
            IFCompoundURI* reference = [context.uriSchemeContext valueForKey:compUri.scheme];
            if (reference) {
                compUri = [schemeHandler resolve:compUri against:reference];
            }
        }
        // Dereference the current URI.
        value = [schemeHandler dereference:compUri parameters:params parent:context];
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Handler not found for scheme %@:", compUri.scheme];
        @throw [[NSException alloc] initWithName:@"IFURIResolver" reason:reason userInfo:nil];
    }
    return value;
}

#pragma mark - private

- (IFCompoundURI *)promoteToCompoundURI:(id)uri {
    // Attempt to promote the argument to a compound URI by first converting to a string, followed
    // by parsing the string.
    NSError *error;
    NSString *uriString;
    if ([uri isKindOfClass:[NSString class]]) {
        uriString = (NSString *)uri;
    }
    else {
        uriString = [uri description];
    }
    IFCompoundURI *compUri = [IFCompoundURI parse:uriString error:&error];
    if (error) {
        NSString *reason = [NSString stringWithFormat:@"Error parsing URI %@ code: %ld message: %@", uriString, (long)error.code, [error.userInfo valueForKey:@"message"]];
        @throw [[NSException alloc] initWithName:@"IFURIResolver" reason:reason userInfo:nil];
    }
    return compUri;
}

@end
