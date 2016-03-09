//
//  IFIOCLabelProxy.h
//  SemoCore
//
//  Created by Julian Goacher on 04/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFIOCProxyObject.h"
#import "IFTextStyle.h"

@interface IFUILabelProxy : IFIOCProxyObject {
    UILabel *_label;
}

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) IFTextStyle *style;

@end
