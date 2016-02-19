//
//  IFLogging.h
//  SemoCore
//
//  Created by Julian Goacher on 22/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#ifndef SemoCore_IFLogging_h
#define SemoCore_IFLogging_h

#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#define IFCoreLogLevel LOG_LEVEL_VERBOSE

static const int ddLogLevel = IFCoreLogLevel;

#define LogTag ([self.class description])

#endif
