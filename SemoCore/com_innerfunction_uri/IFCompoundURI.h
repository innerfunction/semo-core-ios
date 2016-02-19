//
//  IFCompoundURI.h
//  EventPacComponents
//
//  Created by Julian Goacher on 10/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IFCompoundURIParseError                     1
#define IFCompoundURIUnbalancedBracket              2
#define IFCompoundURIInvalidNameRef                 3
#define IFCompoundURITrailingAfterParamAssignment   4

@interface IFCompoundURI : NSObject

@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fragment;
@property (nonatomic, strong) NSDictionary *parameters;

- (id)initWithURI:(NSString *)uri error:(NSError **)error;
- (id)initWithURI:(NSString *)uri trailing:(NSString **)trailing error:(NSError **)error;
- (id)initWithScheme:(NSString *)scheme name:(NSString *)name;
- (id)initWithScheme:(NSString *)scheme uri:(IFCompoundURI *)uri;
- (void)addURIParameters:(NSDictionary *)params;
- (NSString *)canonicalForm;
- (IFCompoundURI *)copyOf;
- (IFCompoundURI *)copyOfWithFragment:(NSString *)fragment;
+ (IFCompoundURI *)parse:(NSString *)uri error:(NSError **)error;

@end
