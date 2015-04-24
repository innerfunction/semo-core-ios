//
//  IFI18nMap.h
//
//  Created by Julian Goacher on 23/07/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFI18nMap : NSObject

- (id)valueForKey:(NSString *)key;

+ (IFI18nMap *)instance;

@end
