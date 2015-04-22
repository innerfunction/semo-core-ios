//
//  IFURIResolver.h
//  EventPacComponents
//
//  Created by Julian Goacher on 12/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFCompoundURI.h"
#import "IFSchemeHandler.h"

@protocol IFURIResolver <NSObject>

- (IFResource *)resolveURIFromString:(NSString *)uri;
- (IFResource *)resolveURI:(IFCompoundURI *)uri;
- (IFResource *)resolveURIFromString:(NSString *)uri context:(IFResource *)context;
- (IFResource *)resolveURI:(IFCompoundURI *)uri context:(IFResource *)context;

@end

// A class for resolving internal URIs.
@interface IFStandardURIResolver : NSObject <IFURIResolver> {
    NSMutableDictionary *schemeHandlers;
}

@property (nonatomic, strong) IFResource *parentResource;

- (id)initWithMainBundlePath:(NSString *)mainBundlePath;

- (BOOL)hasHandlerForURIScheme:(NSString *)scheme;
- (void)addHandler:(id<IFSchemeHandler>)handler forScheme:(NSString *)scheme;
- (NSArray *)getURISchemeNames;
- (id<IFSchemeHandler>)getHandlerForURIScheme:(NSString *)scheme;

@end
