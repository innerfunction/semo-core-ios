//
//  IFFileIO.h
//  EPCore
//
//  Created by Julian Goacher on 03/07/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFFileIO : NSObject

// Read a file and parse its contents as JSON.
+ (id)readJSONFromFileAtPath:(NSString *)path encoding:(NSStringEncoding)encoding;

// Unzip an archive to the specified location.
+ (BOOL)unzipFileAtPath:(NSString *)zipPath toPath:(NSString *)outPath;

@end
