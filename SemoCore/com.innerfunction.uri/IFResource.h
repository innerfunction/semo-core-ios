//
//  IFURIResource.h
//  EventPacComponents
//
//  Created by Julian Goacher on 17/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IFCompoundURI.h"
#import "IFURIHandling.h"

// Interface for accessing different representations of a resource returned by the 
// internal URI resolver.
// Different resource types don't need to provide all representations, and can return
// nil if they don't support any particular representation.
@interface IFResource : NSObject <IFURIHandler, IFResourceContext> {
}

// The resource data.
@property (nonatomic, strong) id data;
// The URI used to reference this resource.
@property (nonatomic, strong) IFCompoundURI *uri;

- (id)initWithData:(id)data uri:(IFCompoundURI *)uri parent:(id<IFResourceContext>)parent;
// Access the resource's boolean representation.
- (BOOL)asBoolean;
// Access the resource's default representation.
- (id)asDefault;
// Return the resource as an image. Returns an image whose name is this resource's string representation.
// Note: Compare this with behaviour of [IFFileURIResource asImage].
- (UIImage *)asImage;
// Access the resource's JSON representation.
// Returns the string representation parsed as a JSON string.
- (id)asJSONData;
// Access the resource's number representation.
- (NSNumber *)asNumber;
// Access the resource's string representation.
- (NSString *)asString;
// Access the resource's URL representation.
- (NSURL *)asURL;
// Return the resource as an NSData object.
- (NSData *)asData;
// Return the named resource representation.
// Recognizes the following representation names:
// * default
// * string
// * number
// * json
// * url
- (id)asRepresentation:(NSString *)representation;
// Return an external URL for the resource.
- (NSURL *)externalURL;
// Refresh the resource by resolving its URI again and returning the result.
- (IFResource *)refresh;

@end