//
//  IFNamedScheme.h
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFURIHandling.h"

@class IFContainer;

@interface IFNamedSchemeHandler : NSObject <IFSchemeHandler> {
    IFContainer *_container;
}

- (id)initWithContainer:(IFContainer *)container;

@end
