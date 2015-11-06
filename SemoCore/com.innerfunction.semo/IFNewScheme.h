//
//  IFNewScheme.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFURIHandling.h"
#import "IFContainer.h"

/**
 * Handler for the new: scheme.
 * Allows objects to be instantiated from a URI.
 */
@interface IFNewScheme : NSObject <IFSchemeHandler> {
    IFContainer *container;
}

- (id)initWithContainer:(IFContainer *)_container;

@end
