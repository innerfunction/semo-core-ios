//
//  IFI18nMap.m
//
//  Created by Julian Goacher on 23/07/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import "IFI18nMap.h"

@implementation IFI18nMap

- (id)valueForKey:(NSString *)key {
    NSString *s = NSLocalizedString(key, @"");
    return s ? s : key;
}

static IFI18nMap *instance;

+ (void)initialize {
    instance = [[IFI18nMap alloc] init];
}

+ (IFI18nMap *)instance {
    return instance;
}

@end
