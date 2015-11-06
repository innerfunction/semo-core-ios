//
//  IFMakeScheme.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFURIHandling.h"
#import "IFContainer.h"

/**
 * Handler for the make: scheme.
 * Allows objects to be built a URI referencing a pre-defined configuration.
 */
@interface IFMakeScheme : NSObject <IFSchemeHandler> {
    IFContainer *container;
}

- (id)initWithContainer:(IFContainer *)_container;


@end
