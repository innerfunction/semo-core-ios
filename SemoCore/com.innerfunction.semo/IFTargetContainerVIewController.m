//
//  IFTargetContainerViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFTargetContainerViewController.h"
#import "IFLogging.h"

@implementation IFTargetContainerViewController

@synthesize parentTargetContainer;

- (id)init {
    self = [super init];
    if (self) {
        containerBehaviour = [[IFDefaultTargetContainerBehaviour alloc] init];
        containerBehaviour.owner = self;
        _namedViews = [NSDictionary dictionary];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    self = [self init];
    if (self) {
        self.view = view;
    }
    return self;
}

- (void)loadView {
    // If no view already specified and a layout name has been specified then load the nib file of
    // that name.
    if (!self.view && _layoutName) {
        // A map of named views can be configured on this object. Use named proxy objects in the nib
        // file to specify where to insert these views into the layout.
        NSDictionary *options = @{ UINibExternalObjects: _namedViews };
        NSArray *result = [[NSBundle mainBundle] loadNibNamed:_layoutName owner:self options:options];
        if ([result count] == 0) {
            DDLogWarn(@"%@: Unable to load nib file %@.xib", LogTag, _layoutName);
        }
    }
}

- (void)setNamedViews:(NSDictionary *)namedViews {
    _namedViews = namedViews;
    self.namedTargets = namedViews;
}

- (void)setUriRewriteRules:(IFStringRewriteRules *)uriRewriteRules {
    _uriRewriteRules = uriRewriteRules;
    containerBehaviour.uriRewriteRules = uriRewriteRules;
}

- (void)setNamedTargets:(NSDictionary *)namedTargets {
    _namedTargets = namedTargets;
    containerBehaviour.namedTargets = namedTargets;
}

- (BOOL)dispatchURI:(NSString *)uri {
    return [containerBehaviour dispatchURI:uri];
}

- (void)doAction:(IFDoAction *)action {
    if ([@"open" isEqualToString:action.name]) {
        id view = [action.parameters valueForKey:@"view"];
        if ([view isKindOfClass:[UIView class]]) {
            // TODO: Animated view transitions.
            self.view = view;
        }
    }
}

@end
