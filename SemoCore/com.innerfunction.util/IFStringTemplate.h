//
//  EPStringTemplate.h
//  EventPacComponents
//
//  Created by Julian Goacher on 12/04/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef NSString* (^EPStringTemplateBlock) (id context);

@interface IFStringTemplate : NSObject {
    NSMutableArray* blocks;
}

@property (nonatomic, strong) NSArray *refs;

- (id)initWithString:(NSString*)s;
- (NSString*)render:(id)context;
+ (IFStringTemplate*)templateWithString:(NSString*)s;
+ (NSString*)render:(NSString*)t context:(id)context;

@end
