//
//  IFFileIO.m
//  EPCore
//
//  Created by Julian Goacher on 03/07/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import "IFFileIO.h"
#import "JSONKit.h"
#import "ZipArchive.h"
#import "IFLogging.h"

@interface IFZipArchiveDelegate : NSObject <ZipArchiveDelegate> {
    NSString *zipPath;
}

- (id)initWithZipPath:(NSString *)zipPath;

@end

@implementation IFFileIO

// Read a file and parse its contents as JSON.
+ (id)readJSONFromFileAtPath:(NSString *)path encoding:(NSStringEncoding)encoding {
    id result = nil;
    NSError *error = nil;
    NSString *json = [[NSString alloc] initWithContentsOfFile:path encoding:encoding error:&error];
    if (error) {
        DDLogError(@"IFFileIO: Error reading contents of file %@: %@", path, error);
    }
    else {
        result = [json objectFromJSONString];
    }
    return result;
}

// Unzip an archive to the specified location.
+ (BOOL)unzipFileAtPath:(NSString *)zipPath toPath:(NSString *)outPath {
    BOOL ok = NO;
    ZipArchive *archive = [[ZipArchive alloc] init];
    archive.delegate = [[IFZipArchiveDelegate alloc] initWithZipPath:zipPath];
    if ([archive UnzipOpenFile:zipPath]) {
        if ([archive UnzipFileTo:outPath overWrite:YES]) {
            ok = YES;
        }
        else {
            DDLogError(@"IFFileIO: Failed to unzip %@ to %@", zipPath, outPath );
        }
        [archive UnzipCloseFile];
    }
    else {
        DDLogError(@"IFFileIO: Failed to open zip file %@", zipPath);
    }
    return ok;
}

@end

@implementation IFZipArchiveDelegate

- (id)initWithZipPath:(NSString *)_zipPath {
    self = [super init];
    if (self) {
        zipPath = _zipPath;
    }
    return self;
}

#pragma mark - ZipArchiveDelegate

- (void)ErrorMessage:(NSString *)msg {
    DDLogError(@"IFFileIO: Error processing zip file %@: %@", zipPath, msg);
}


@end
