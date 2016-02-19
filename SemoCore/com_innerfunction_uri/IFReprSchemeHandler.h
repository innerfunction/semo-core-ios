//
//  IFReprSchemeHandler.h
//  SemoCore
//
//  Created by Julian Goacher on 11/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFURIHandling.h"

// The repr: scheme is used to access specific representations of URI resources.
// If is useful only in very particular cases, e.g. where the default resolved representation
// isn't what is actually needed.
@interface IFReprSchemeHandler : NSObject <IFSchemeHandler>

@end
