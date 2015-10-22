//
//  IFViewContainerBehaviour.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFActionTargetContainerBehaviour.h"
#import "IFCompoundURI.h"
#import "IFResource.h"
#import "IFActionTarget.h"
#import "IFLogging.h"

@implementation IFActionTargetContainerBehaviour

@synthesize parentActionTargetContainer;

// TODO: Problem with the approach below is that descendent contains might make changes to their
// contents (i.e. have children added or removed) which won't then be reflected in this container.
- (void)setNamedTargets:(NSDictionary *)namedTargets {
    NSMutableDictionary *__namedTargets = [[NSMutableDictionary alloc] init];
    for (NSString *name in [namedTargets keyEnumerator]) {
        id target = [namedTargets objectForKey:name];
        [__namedTargets setObject:target forKey:name];
        if ([target conformsToProtocol:@protocol(IFActionTargetContainer)]) {
            id<IFActionTargetContainer> container = (id<IFActionTargetContainer>)target;
            // Wire up the container heirarchy.
            container.parentActionTargetContainer = self;
            // Add the container's named targets to this container using the target's name as a prefix.
            // This is to facilitate fast dispatching of targeted action URIs.
            // Note that this requires that all the child container's children are populated before
            // being passed to the parent container.
            for (NSString *grandchildName in container.namedTargets) {
                NSString *qualifiedName = [NSString stringWithFormat:@"%@.%@", name, grandchildName];
                [__namedTargets setObject:[container.namedTargets objectForKey:grandchildName] forKey:qualifiedName];
            }
        }
    }
    _namedTargets = __namedTargets;
}

- (BOOL)dispatchURI:(NSString *)uri {
    IFCompoundURI *curi = nil;
    NSError *error;
    if ([uri hasPrefix:@"do:"]) {
        curi = [[IFCompoundURI alloc] initWithURI:uri error:&error];
    }
    if (!curi && _uriRewriteRules) {
        NSString *_uri = [_uriRewriteRules rewriteString:uri];
        if (_uri) {
            if ([_uri hasPrefix:@"do:"]) {
                curi = [[IFCompoundURI alloc] initWithURI:uri error:&error];
            }
            else {
                DDLogWarn(@"%@: Rewritten URI not in 'do' scheme: %@ -> %@", LogTag, uri, _uri );
            }
        }
    }
    if (error) {
        DDLogError(@"%@: URI parse error %@", LogTag, error );
    }
    BOOL dispatched = NO;
    if (curi) {
        // Check for a named target, else dispatch the action to the behaviour owner.
        id target = curi.fragment ? [_namedTargets valueForKey:curi.fragment] : _owner;
        // If target resolved then dereference the URI and apply the resource to the target
        if (target && [target conformsToProtocol:@protocol(IFActionTarget)]) {
            IFDoAction *action = (IFDoAction *)[_uriResolver dereference:curi];
            [(id<IFActionTarget>)action doAction:action];
            dispatched = YES;
        }
    }
    // If unable to dispatch the URI then try sending to the parent container.
    if (!dispatched && parentActionTargetContainer) {
        dispatched = [parentActionTargetContainer dispatchURI:uri];
    }
    return dispatched;
}

@end
