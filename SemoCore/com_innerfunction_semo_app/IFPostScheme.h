//
//  IFPostScheme.h
//  SemoCore
//
//  Created by Julian Goacher on 25/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFURIHandling.h"

@interface IFPostAction : NSObject {
    BOOL _absTarget;
    NSArray *_targetPath;
}

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDictionary *parameters;

- (id)initWithTarget:(NSString *)target message:(NSString *)message parameters:(NSDictionary *)parameters;
- (id)initWithTargetPath:(NSArray *)targetPath message:(NSString *)message parameters:(NSDictionary *)parameters;
/** Check whether the action has an absolute target path (i.e. a path prefixed with /). */
- (BOOL)hasAbsoluteTarget;
/** Get the target name at the head of the target path. */
- (NSString *)targetHead;
/**
 * Pop the head name from the target path and return a new action whose target path is the remained.
 * Return nil if there is no trailing target path.
 */
- (IFPostAction *)popTargetHead;
/** Get a named action parameter value. */
- (id)parameterValue:(NSString *)name;

@end

@interface IFPostScheme : NSObject <IFSchemeHandler>

@end
