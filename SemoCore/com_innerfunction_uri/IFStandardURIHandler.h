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
    NSMutableDictionary *_schemeHandlers;
    NSDictionary *_schemeContexts;
}

- (id)initWithSchemeContexts:(NSDictionary *)schemeContexts;
- (id)initWithMainBundlePath:(NSString *)mainBundlePath schemeContexts:(NSDictionary *)schemeContexts;

@end
