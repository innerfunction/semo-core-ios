//
//  IFJSONData.h
//  EventPacComponents
//
//  Created by Julian Goacher on 23/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface IFJSONPropertyHandler : NSObject {
}

- (id)resolveName:(NSString *)name on:(id)value representation:(NSString *)representation;;
- (id)modifyValue:(id)value forName:(id)name representation:(NSString *)representation;

@end

@interface IFJSONData : NSObject

+ (IFJSONPropertyHandler *)getDefaultHandler;

// Resolve a dotted data reference (e.g. a.b.c) on the specified data.
+ (id)resolvePath:(NSString *)path onData:(id)data;

// Resolve a dotted data reference with the specified property handler.
+ (id)resolvePath:(NSString *)path onData:(id)data handler:(IFJSONPropertyHandler *)handler representation:(NSString *)representation;

@end
