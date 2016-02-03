//
//  IFViewContainerBehaviour.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFDefaultTargetContainerBehaviour.h"
#import "IFCompoundURI.h"
#import "IFResource.h"
#import "IFTarget.h"
#import "IFLogging.h"
#import "NSString+IF.h"

@implementation IFDefaultTargetContainerBehaviour

@synthesize parentTargetContainer = _parentTargetContainer, namedTargets = _namedTargets, uriHandler = _uriHandler;

- (void)setNamedTargets:(NSDictionary *)namedTargets {
    _namedTargets = namedTargets;
    for (id name in [_namedTargets keyEnumerator]) {
        id target = [_namedTargets valueForKey:name];
        if ([target conformsToProtocol:@protocol(IFTargetContainer)]) {
            // TODO: Child target parent is this, or the behaviour owner?
            ((id<IFTargetContainer>)target).parentTargetContainer = self;
        }
    }
}

- (BOOL)dispatchURI:(NSString *)uri {
    IFCompoundURI *curi = nil;
    NSError *error;
    // Resolve the action URI.
    if ([uri hasPrefix:@"do:"]) {
        curi = [[IFCompoundURI alloc] initWithURI:uri error:&error];
    }
    if (!curi && _uriRewriteRules) {
        NSString *_uri = [_uriRewriteRules rewriteString:uri];
        if (_uri) {
            if ([_uri hasPrefix:@"do:"]) {
                curi = [[IFCompoundURI alloc] initWithURI:_uri error:&error];
            }
            else {
                DDLogWarn(@"%@: Rewritten URI not in 'do' scheme: %@ -> %@", LogTag, uri, _uri );
            }
        }
    }
    if (error) {
        DDLogError(@"%@: URI parse error %@", LogTag, error );
    }
    // Dispatch the action URI.
    BOOL dispatched = NO;
    if (curi) {
        // Resolve the action target.
        id target = [self targetForPath:curi.fragment];
        // If target resolved then dereference the URI and apply the resource to the target.
        if (target && [target conformsToProtocol:@protocol(IFTarget)]) {
            IFDoAction *action = (IFDoAction *)[_uriHandler dereference:curi];
            [(id<IFTarget>)target doAction:action];
            dispatched = YES;
        }
    }
    // If unable to dispatch the URI then try sending to the parent container.
    if (!dispatched && _parentTargetContainer) {
        dispatched = [_parentTargetContainer dispatchURI:uri];
    }
    return dispatched;
}

- (id)targetForPath:(NSString *)targetPath {
    if (!targetPath || [targetPath length] == 0) {
        return _owner;
    }
    NSArray *components = [targetPath split:@"\\."];
    NSDictionary *targets = _namedTargets;
    id target = nil;
    for (NSInteger i = 0; i < [components count]; i++) {
        // If no named targets then don't continue.
        if (!targets) {
            target = nil;
            break;
        }
        // Resolve the next named target.
        NSString *name = [components objectAtIndex:i];
        target = [targets objectForKey:name];
        if (!target) {
            // Name not found, so don't continue.
            break;
        }
        // Check if next target is a container, and if so resolve its named children.
        if ([target conformsToProtocol:@protocol(IFTargetContainer)]) {
            targets = ((id<IFTargetContainer>)target).namedTargets;
        }
        else {
            // Can't resolved named children - this won't matter for the final path component,
            // but will for intermediate components, in which case the code at the head of the
            // loop will exit.
            targets = nil;
        }
    }
    return target;
}

@end
