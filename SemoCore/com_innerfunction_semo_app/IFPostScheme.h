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
    NSString *_target;
    NSArray *_targetPath;
}

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDictionary *parameters;

- (id)initWithTarget:(NSString *)target message:(NSString *)message parameters:(NSDictionary *)parameters;
- (id)initWithTargetPath:(NSArray *)targetPath message:(NSString *)message parameters:(NSDictionary *)parameters;
/** Test whether the action has an empty target. */
- (BOOL)hasEmptyTarget;
/** Test if the (entire) target matches the specified string. */
- (BOOL)hasTarget:(NSString *)target;
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
