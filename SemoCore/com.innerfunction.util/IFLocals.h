//
//  IFLocals.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFLocals : NSObject {
    NSString *namespacePrefix;
    NSUserDefaults *preferences;
}

- (id)init;
- (id)initWithPrefix:(NSString *)prefix;

- (void)setValues:(NSDictionary *)values forceReset:(BOOL)forceReset;

- (NSString *)getStringForName:(NSString *)name;
- (NSString *)getStringForName:(NSString *)name defaultValue:(NSString *)defaultValue;
- (NSString *)setStringForName:(NSString *)name value:(NSString *)value;

- (NSInteger)getIntegerForName:(NSString *)name;
- (NSInteger)getIntegerForName:(NSString *)name defaultValue:(NSInteger)defaultValue;
- (NSInteger)setIntegerForName:(NSString *)name value:(NSInteger)value;

- (BOOL)getBooleanForName:(NSString *)name;
- (BOOL)getBooleanForName:(NSString *)name defaultValue:(BOOL)defaultValue;
- (BOOL)setBooleanForName:(NSString *)name value:(BOOL)value;

- (void)removeName:(NSString *)name;
- (void)removeNames:(NSArray *)names;

@end
