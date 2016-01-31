//
//  IFURIResolver.h
//  EventPacComponents
//
//  Created by Julian Goacher on 12/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFCompoundURI.h"
#import "IFURIHandling.h"

@interface IFStandardURIHandler : NSObject <IFURIHandler> {
    NSMutableDictionary *schemeHandlers;
    id<IFResourceContext> resourceContext;
}

- (id)initWithResourceContext:(id<IFResourceContext>)context;
- (id)initWithMainBundlePath:(NSString *)mainBundlePath resourceContext:(id<IFResourceContext>)context;

@end
