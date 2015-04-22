//
//  IFFileResource.h
//  EPCore
//
//  Created by Julian Goacher on 02/07/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFResource.h"

// An object describing a file resource.
@interface IFFileDescription : NSObject

- (id)initWithHandle:(NSFileHandle *)handle url:(NSURL *)url path:(NSString *)path;

@property (nonatomic, strong) NSFileHandle *handle;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *path;

@end

@interface IFFileResource : IFResource

@property (nonatomic, strong) IFFileDescription *fileDescription;

@end
