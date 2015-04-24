//
//  IFContainer.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFConfiguration.h"
#import "IFService.h"

@interface IFContainer : NSObject <IFService> {
    NSMutableDictionary *named;
    NSMutableArray *services;
    IFConfiguration *types;
    BOOL running;
}

- (id)getNamed:(NSString *)name;
- (void)setTypes:(IFConfiguration *)types;
- (id)buildObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
- (id)instantiateObjectWithConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
- (id)newInstanceForClassName:(NSString *)className;
- (void)configureObject:(id)object withConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier;
- (void)configureWith:(IFConfiguration *)configuration;

@end
