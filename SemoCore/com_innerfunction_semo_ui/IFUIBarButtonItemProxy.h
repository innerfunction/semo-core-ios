//
//  IFUIBarButtonItemProxy.h
//  SemoCore
//
//  Created by Julian Goacher on 08/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFIOCProxyObject.h"
#import "IFIOCObjectAware.h"

@interface IFUIBarButtonItemProxy : IFIOCProxyObject <IFIOCObjectAware> {
    UIBarButtonItem *_barButtonItem;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *action;

@end
