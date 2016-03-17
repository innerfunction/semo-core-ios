// Copyright 2016 InnerFunction Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Julian Goacher on 03/07/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Utility class for common file operations.
 */
@interface IFFileIO : NSObject

/**
 * Read a file and parse its contents as JSON.
 * @param path      The path to the JSON file.
 * @param encoding  The text encoding of its contents.
 * @return An object representing the file's parsed contents.
 */
+ (id)readJSONFromFileAtPath:(NSString *)path encoding:(NSStringEncoding)encoding;

/**
 * Unzip a zip archive file to the specified location.
 * @param zipPath   The path to the zip archive file.
 * @param outPath   The location to unzip the file's contents to.
 * @return Returns boolean _true_ if the archive was successfully unzipped.
 */
+ (BOOL)unzipFileAtPath:(NSString *)zipPath toPath:(NSString *)outPath;

@end
