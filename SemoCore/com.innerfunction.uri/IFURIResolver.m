//
//  IFURIResolver.m
//  EventPacComponents
//
//  Created by Julian Goacher on 12/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFURIResolver.h"
#import "IFStringSchemeHandler.h"
#import "IFFileBasedSchemeHandler.h"
#import "IFLocalSchemeHandler.h"
#import "IFResource.h"

#define MainBundlePath  ([[NSBundle mainBundle] resourcePath])

// Internal URI resolver. The resolver is configured with a set of mappings between
// URI scheme names and scheme handlers, which it then uses to resolve compound URIs
// to URI resources.
@implementation IFStandardURIResolver

- (id)init {
    return [self initWithMainBundlePath:MainBundlePath];
}

- (id)initWithMainBundlePath:(NSString *)mainBundlePath {
    self = [super init];
    if (self) {
        schemeHandlers = [[NSMutableDictionary alloc] init];
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

// Resolve a resource from a URI string. Returns nil if the resource can't be resolved,
// of if the URI isn't valid.
- (IFResource *)dereferenceString:(NSString *)suri {
    return [self dereferenceString:suri context:self.parentResource];
}

- (IFResource *)dereferenceString:(NSString *)suri context:(IFResource *)context {
    IFResource *resource = nil;
    NSError *error;
    IFCompoundURI *uri = [IFCompoundURI parse:suri error:&error];
    if (error) {
        NSLog(@"IFURIResolver: Error parsing URI %@ code: %ld message: %@", suri, (long)error.code, [error.userInfo valueForKey:@"message"]);
    }
    else {
        resource = [self dereference:uri context:context];
    }
    return resource;
}

// Resolve a resource from a URI string. Returns nil if the resource can't be resolved,
// or if a handler can't be found for the URI scheme.
- (IFResource *)dereference:(IFCompoundURI *)uri {
    return [self dereference:uri context:self.parentResource];
}

- (IFResource *)dereference:(IFCompoundURI *)uri context:(IFResource *)context {
    IFResource *resource = nil;

    // Resolve a handler for the URI scheme.
    id<IFSchemeHandler> schemeHandler = [schemeHandlers valueForKey:uri.scheme];
    if (schemeHandler) {
        // Dictionary of resolved URI parameters.
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:[uri.parameters count]];
        // Iterate over the URIs parameter values (which are also URIs) and resolve each
        // of them.
        for (NSString *name in [uri.parameters allKeys]) {
            IFResource *value = [self dereference:[uri.parameters valueForKey:name] context:context];
            if (value != nil) {
                [params setValue:value forKey:name];
            }
        }
        // Resolve the current URI to an absolute form (potentially).
        if ([schemeHandler respondsToSelector:@selector(resolveToAbsoluteURI:against:)] && context && context.schemeContext ) {
            IFCompoundURI* reference = [context.schemeContext valueForKey:uri.scheme];
            if (reference) {
                uri = [schemeHandler resolve:uri against:reference];
            }
        }
        // Handle the current URI.
        resource = [schemeHandler dereference:uri parameters:params parent:context];
    }
    else {
        NSLog(@"IFURIResolver: Handler not found for scheme %@:", uri.scheme);
    }
    return resource;
}

@end
