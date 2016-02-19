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
#import "IFReprSchemeHandler.h"
#import "IFResource.h"
#import "NSDictionary+IF.h"

#define MainBundlePath  ([[NSBundle mainBundle] resourcePath])

@interface IFStandardURIHandler()

- (id)initWithMainBundlePath:(NSString *)mainBundlePath schemeHandlers:(NSMutableDictionary *)schemeHandlers schemeContexts:(NSDictionary *)schemeContexts;
- (IFCompoundURI *)promoteToCompoundURI:(id)uri;

@end

// Internal URI resolver. The resolver is configured with a set of mappings between
// URI scheme names and scheme handlers, which it then uses to resolve compound URIs
// to URI resources.
@implementation IFStandardURIHandler

- (id)init {
    return [self initWithMainBundlePath:MainBundlePath schemeContexts:[NSDictionary dictionary]];
}

- (id)initWithSchemeContexts:(NSDictionary *)schemeContexts {
    return [self initWithMainBundlePath:MainBundlePath schemeContexts:schemeContexts];
}

- (id)initWithMainBundlePath:(NSString *)mainBundlePath schemeContexts:(NSDictionary *)schemeContexts {
    return [self initWithMainBundlePath:mainBundlePath schemeHandlers:[[NSMutableDictionary alloc] init] schemeContexts:schemeContexts];
}

- (id)initWithMainBundlePath:(NSString *)mainBundlePath schemeHandlers:(NSMutableDictionary *)schemeHandlers schemeContexts:(NSDictionary *)schemeContexts {
    self = [super init];
    if (self) {
        _schemeHandlers = schemeHandlers;
        _schemeContexts = schemeContexts;
        // Add standard schemes.
        [_schemeHandlers setValue:[[IFStringSchemeHandler alloc] init]
                          forKey:@"s"];
        // See following for info on iOS file system dirs.
        // https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/Reference/reference.html
        // http://developer.apple.com/library/ios/#documentation/FileManagement/Conceptual/FileSystemProgrammingGUide/FileSystemOverview/FileSystemOverview.html
        // TODO: app: scheme handler not resolving (in simulator anyway):
        // Resolved path: /Users/juliangoacher/Library/Application\ Support/iPhone\ Simulator/5.0/Applications/F578A85D-A358-4897-A0BE-9BE8714B50D4/Applications/
        // Actual path:   /Users/juliangoacher/Library/Application\ Support/iPhone\ Simulator/5.0/Applications/F578A85D-A358-4897-A0BE-9BE8714B50D4/EventPacComponents.app/
        [_schemeHandlers setValue:[[IFFileBasedSchemeHandler alloc] initWithPath:mainBundlePath]
                           forKey:@"app"];
        [_schemeHandlers setValue:[[IFFileBasedSchemeHandler alloc] initWithDirectory:NSCachesDirectory]
                           forKey:@"cache"];
        [_schemeHandlers setValue:[[IFLocalSchemeHandler alloc] init]
                           forKey:@"local"];
        [_schemeHandlers setValue:[[IFReprSchemeHandler alloc] init]
                           forKey:@"repr"];
    }
    return self;
}

// Test whether this resolver has a handler for a URI's scheme.
- (BOOL)hasHandlerForURIScheme:(NSString *)scheme {
    return [_schemeHandlers valueForKey:scheme] != nil;
}

// Register a new scheme handler.
- (void)addHandler:(id<IFSchemeHandler>)handler forScheme:(NSString *)scheme {
    [_schemeHandlers setValue:handler forKey:scheme];
}

// Return a list of registered URI scheme names.
- (NSArray *)getURISchemeNames {
    return [_schemeHandlers allKeys];
}

// Return the URI handler for the named scheme.
- (id<IFSchemeHandler>)getHandlerForURIScheme:(NSString *)scheme {
    return [_schemeHandlers valueForKey:scheme];
}

- (id)dereference:(id)uri {
    IFCompoundURI *compUri;
    if ([uri isKindOfClass:[IFCompoundURI class]]) {
        compUri = (IFCompoundURI *)uri;
    }
    else {
        compUri = [self promoteToCompoundURI:uri];
    }
    id value = nil;
    // Resolve a handler for the URI scheme.
    id<IFSchemeHandler> schemeHandler = [_schemeHandlers valueForKey:compUri.scheme];
    if (schemeHandler) {
        // Dictionary of resolved URI parameters.
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:[compUri.parameters count]];
        // Iterate over the URIs parameter values (which are also URIs) and dereference each
        // of them.
        for (NSString *name in [compUri.parameters allKeys]) {
            IFCompoundURI *paramURI = [compUri.parameters valueForKey:name];
            id paramValue = [self dereference:paramURI];
            if (paramValue) {
                [params setValue:paramValue forKey:name];
            }
        }
        // Resolve the current URI to an absolute form (potentially).
        if ([schemeHandler respondsToSelector:@selector(resolve:against:)]) {
            IFCompoundURI *reference = [_schemeContexts valueForKey:compUri.scheme];
            if (reference) {
                compUri = [schemeHandler resolve:compUri against:reference];
            }
        }
        // Dereference the current URI.
        value = [schemeHandler dereference:compUri parameters:params];
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Handler not found for scheme %@:", compUri.scheme];
        @throw [[NSException alloc] initWithName:@"IFURIResolver" reason:reason userInfo:nil];
    }
    // If the value is a resource then set its URI, and its URI handler as a copy of this handler,
    // with the scheme context modified with the resource's URI.
    if ([value isKindOfClass:[IFResource class]]) {
        IFResource *resource = (IFResource *)value;
        resource.uri = compUri;
        resource.uriHandler = [self modifySchemeContext:compUri];
    }
    return value;
}

- (id<IFURIHandler>)modifySchemeContext:(IFCompoundURI *)uri {
    IFStandardURIHandler *handler = [[IFStandardURIHandler alloc] init];
    handler->_schemeHandlers = [_schemeHandlers mutableCopy];
    // Create a copy of this object's scheme handlers dictionary with a new entry for
    // the URI argument keyed by the URI's scheme name.
    NSMutableDictionary *schemeContexts = [_schemeContexts mutableCopy];
    [schemeContexts setObject:uri forKey:uri.scheme];
    handler->_schemeContexts = schemeContexts;
    return handler;
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
