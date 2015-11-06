//
//  IFNamedScheme.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFURIHandling.h"

@interface IFNamedSchemeHandler : NSObject <IFSchemeHandler> {
    NSDictionary *named;
}

- (id)initWithNamed:(NSDictionary *)named;

@end
