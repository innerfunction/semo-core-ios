//
//  IFAppContainer.m
//  SemoCore
//
//  Created by Julian Goacher on 23/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFAppContainer.h"
#import "IFConfiguration.h"
#import "IFI18nMap.h"
#import "IFLogging.h"
#import "NSString+IF.h"

@interface IFAppContainer ()

- (NSMutableDictionary *)makeDefaultGlobalModelValues:(IFConfiguration *)configuration;

@end

@interface IFNamedSchemeHandler : NSObject <IFSchemeHandler> {
    NSDictionary *named;
}

- (id)initWithNamed:(NSDictionary *)named;

@end

@implementation IFNamedSchemeHandler

- (id)initWithNamed:(NSDictionary *)_named {
    self = [super init];
    if (self) {
        named = _named;
    }
    return self;
}

- (IFCompoundURI *)resolveToAbsoluteURI:(IFCompoundURI *)uri against:(IFCompoundURI *)reference {
    return uri;
}

- (IFResource *)handle:(IFCompoundURI *)uri parameters:(NSDictionary *)params parent:(IFResource *)parent {
    id namedObj = [named objectForKey:uri.name];
    return namedObj ? [[IFResource alloc] initWithData:namedObj uri:uri parent:parent] : nil;
}

@end

@implementation IFAppContainer

- (id)init {
    self = [super init];
    if (self) {
        resolver = [[IFStandardURIResolver alloc] init];
    }
    return self;
}

- (void)loadConfiguration:(id)configSource {
    IFConfiguration *configuration = nil;
    if ([configSource isKindOfClass:[IFConfiguration class]]) {
        configuration = (IFConfiguration *)configSource;
    }
    else {
        IFCompoundURI *uri = nil;
        if ([configSource isKindOfClass:[IFCompoundURI class]]) {
            uri = (IFCompoundURI *)configSource;
        }
        else if ([configSource isKindOfClass:[NSString class]]) {
            NSError *error = nil;
            uri = [[IFCompoundURI alloc] initWithURI:(NSString *)configSource error:&error];
            if (error) {
                DDLogCError(@"Error parsing app container configuration URI: %@", error);
                return;
            }
        }
        
        if (uri) {
            DDLogInfo(@"Loading app container configuration from %@", uri);
            IFResource *resource = [resolver resolveURI:uri];
            configuration = [[IFConfiguration alloc] initWithResource:resource];
        }
        else {
            DDLogInfo(@"Attempting to configure app container with data...");
            configuration = [[IFConfiguration alloc] initWithData:configSource];
        }
    }
    [self configureWith:configuration];
}

- (void)configureWith:(IFConfiguration *)configuration {
    
    // Setup template context.
    globals = [self makeDefaultGlobalModelValues:configuration];
    configuration.context = globals;
    
    // Set object type mappings.
    types = [configuration getValueAsConfiguration:@"types"];
    
    // Add additional schemes to the resolver/dispatcher.
    [resolver addHandler:[[IFNamedSchemeHandler alloc] initWithNamed:named] forScheme:@"named"];
    
    IFConfiguration *dispatcherConfig = [configuration getValueAsConfiguration:@"schemes"];
    if (dispatcherConfig) {
        for (NSString *schemeName in [dispatcherConfig getValueNames]) {
            IFConfiguration *schemeConfig = [dispatcherConfig getValueAsConfiguration:schemeName];
            id handler = [self buildObjectWithConfiguration:schemeConfig identifier:schemeName];
            if ([handler conformsToProtocol:@protocol(IFSchemeHandler)]) {
                [resolver addHandler:handler forScheme:schemeName];
            }
        }
    }
    
    // Default local settings.
    locals = [[IFLocals alloc] initWithPrefix:@"semo"];
    NSDictionary *settings = (NSDictionary *)[configuration getValue:@"settings"];
    if (settings) {
        [locals setValues:settings forceReset:ForceResetDefaultSettings];
    }
    
    [named setObject:resolver forKey:@"resolver"];
    [named setObject:globals forKey:@"globals"];
    [named setObject:locals forKey:@"locals"];
    [named setObject:self forKey:@"container"];
    
    // Perform default container configuration.
    [super configureWith:configuration];
}

- (NSMutableDictionary *)makeDefaultGlobalModelValues:(IFConfiguration *)configuration {
    
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    float scale = [UIScreen mainScreen].scale;
    NSString *display = scale > 1.0 ? [NSString stringWithFormat:@"%f.0x", scale] : @"";
    NSDictionary *platformValues = @{
                                     @"name": Platform,
                                     @"dispay": display,
                                     @"defaultDisplay": @"2x",
                                     @"full": [NSString stringWithFormat:@"ios%@", display]
                                     };
    [values setObject:platformValues forKey:@"platform"];
    
    NSString *mode = [configuration getValueAsString:@"mode" defaultValue:@"LIVE"];
    DDLogInfo(@"Configuration mode: %@", mode);
    [values setObject:mode forKey:@"mode"];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *lang = nil;
    DDLogInfo(@"Current locale is %@", locale.localeIdentifier);
    
    // The 'assetLocales' setting can be used to declare a list of the locales that app assets are
    // available in. If the platform's default locale (above) isn't on this list then the code below
    // will attempt to find a supported locale that uses the same language; if no match is found then
    // the first locale on the list is used as the default.
    if ([configuration hasValue:@"assetLocales"]) {
        NSArray *assetLocales = [configuration getValue:@"assetLocales"];
        if ([assetLocales count] > 0 && ![assetLocales containsObject:locale.localeIdentifier]) {
            // Attempt to find a matching locale.
            // Always assigns the first item on the list (as the default option); if a later
            // item has a matching language then that is assigned and the loop is exited.
            NSString *lang = [locale objectForKey:NSLocaleLanguageCode];
            BOOL langMatch = NO, assignDefault;
            for (NSInteger i = 0; i < [assetLocales count] && !langMatch; i++) {
                NSString *assetLocale = [assetLocales objectAtIndex:0];
                NSArray *localeParts = [assetLocale split:@"_"];
                assignDefault = (i == 0);
                langMatch = [[localeParts objectAtIndex:0] isEqualToString:lang];
                if (assignDefault||langMatch) {
                    locale = [NSLocale localeWithLocaleIdentifier:assetLocale];
                }
            }
        }
        // Handle the case where the user's selected language is different from the locale.
        // See http://stackoverflow.com/questions/3910244/getting-current-device-language-in-ios
        NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
        if (![[locale objectForKey:NSLocaleLanguageCode] isEqualToString:preferredLang]) {
            // Use the user's selected language if listed in assetLocales.
            for (NSString *assetLocale in assetLocales) {
                NSArray *localeParts = [assetLocale split:@"_"];
                if ([[localeParts objectAtIndex:0] isEqualToString:preferredLang]) {
                    lang = preferredLang;
                    break;
                }
            }
        }
    }
    
    if (!lang) {
        // If the user's preferred language hasn't been selected, then use the current locale's.
        lang = [locale objectForKey:NSLocaleLanguageCode];
    }
    DDLogInfo(@"Using language %@", lang);
    
    NSDictionary *localeValues = @{
                                   @"id": [locale objectForKey:NSLocaleIdentifier],
                                   @"lang": lang,
                                   @"variant": [locale objectForKey:NSLocaleCountryCode]
                                   
                                   };
    [values setObject:localeValues forKey:@"locale"];
    [values setObject:[IFI18nMap instance] forKey:@"i18n"];
    
    return values;
}

static IFAppContainer *instance;

+ (void)initialize {
    instance = [[IFAppContainer alloc] init];
}

+ (IFAppContainer *)getAppContainer {
    return instance;
}

@end
