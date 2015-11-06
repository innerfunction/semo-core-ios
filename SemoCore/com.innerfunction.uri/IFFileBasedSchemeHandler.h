//
//  IFFileBasedSchemeHandler.h
//  EventPacComponents
//
//  Created by Julian Goacher on 13/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFResource.h"
#import "IFFileResource.h"

// Scheme handler for resolving files at specified paths. Instances of this handler are
// initialized with directory search paths (defined using standard NS file definitions).
// The handler will then attempt to resolve files under those search directories. The
// URI scheme specific part is used to specify the file path.
@interface IFFileBasedSchemeHandler : NSObject <IFSchemeHandler> {
    NSArray* paths;
}

- (id)initWithDirectory:(NSSearchPathDirectory)directory;
- (id)initWithPath:(NSString*)path;
- (IFResource *)dereference:(IFCompoundURI *)uri againstPath:(NSString *)path parent:(id<IFResourceContext>)parent;

@end