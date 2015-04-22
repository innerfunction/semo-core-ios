//
//  IFResourceObserver.h
//  EPCore
//
//  Created by Julian Goacher on 26/06/2014.
//  Copyright (c) 2014 Julian Goacher. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFResourceObserver <NSObject>

- (void)resourceUpdated:(NSString *)name;

@end
