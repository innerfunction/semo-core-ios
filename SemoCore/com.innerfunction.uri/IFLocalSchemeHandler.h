//
//  IFLocalSchemeHandler.h
//  EventPacComponents
//
//  Created by Julian Goacher on 13/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFResource.h"

@interface IFLocalResource : IFResource {
}

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSUserDefaults *storage;

@end

// Scheme handler for local storage. The URI scheme specific part specifies a local
// storage key.
@interface IFLocalSchemeHandler : NSObject <IFSchemeHandler> {
@private
    NSUserDefaults* storage;
}

@end