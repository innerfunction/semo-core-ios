//
//  IFAppContainer.m
//  SemoCore
//
//  Created by Julian Goacher on 23/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFAppContainer.h"
#import "IFConfiguration.h"
#import "IFTargetContainerViewController.h"
#import "IFDoScheme.h"
#import "IFNewScheme.h"
#import "IFMakeScheme.h"
#import "IFNamedScheme.h"
#import "IFCoreTypes.h"
#import "IFI18nMap.h"
#import "IFLogging.h"
#import "NSString+IF.h"

@interface IFAppContainer ()

- (NSMutableDictionary *)makeDefaultGlobalModelValues:(IFConfiguration *)configuration;

@end

@implementation IFAppContainer

@synthesize uriHandler=_uriHandler, uriSchemeContext=_uriSchemeContext;

- (id)init {
    self = [super init];
    if (self) {
        self.appBackgroundColor = [UIColor redColor];
        self.uriSchemeContext = [NSDictionary dictionary];
        uriHandler = [[IFStandardURIHandler alloc] initWithResourceContext:self];
        self.uriHandler = uriHandler;
        rootTargetContainer = [[IFDefaultTargetContainerBehaviour alloc] init];
        rootTargetContainer.owner = self;
        rootTargetContainer.uriHandler = uriHandler;
    }
    return self;
}

- (void)loadConfiguration:(id)configSource {
    IFConfiguration *configuration = nil;
    if ([configSource isKindOfClass:[IFConfiguration class]]) {
        // Configuration source is already a configuration.
        configuration = (IFConfiguration *)configSource;
    }
    else {
        // Test if config source specifies a URI.
        IFCompoundURI *uri = nil;
        if ([configSource isKindOfClass:[IFCompoundURI class]]) {
            uri = (IFCompoundURI *)configSource;
        }
        else if ([configSource isKindOfClass:[NSString class]]) {
            NSError *error = nil;
            uri = [[IFCompoundURI alloc] initWithURI:(NSString *)configSource error:&error];
            if (error) {
                DDLogCError(@"%@: Error parsing app container configuration URI: %@", LogTag, error);
                return;
            }
        }
        IFResource *resource = nil;
        if (uri) {
            // If a configuration source URI has been resolved then attempt loading the configuration from the URI.
            DDLogInfo(@"%@: Attempting to load app container configuration from %@", LogTag, uri);
            resource = [uriHandler dereference:uri];
            if (resource) {
                configuration = [[IFConfiguration alloc] initWithResource:resource];
            }
        }
        else {
            // No configuration URI, so assume the configuration source is the actual config data.
            DDLogInfo(@"%@: Attempting to configure app container with data...", LogTag);
            configuration = [[IFConfiguration alloc] initWithData:configSource];
        }
    }
    if (configuration) {
        [self configureWith:configuration];
    }
    else {
        DDLogWarn(@"%@: Unable to resolve configuration from %@", LogTag, configSource);
    }
}

- (void)configureWith:(IFConfiguration *)configuration {
    
    // Setup template context.
    globals = [self makeDefaultGlobalModelValues:configuration];
    configuration.context = globals;
    
    // Set object type mappings.
    [self addTypes:[configuration getValueAsConfiguration:@"types"]];
    
    // Add additional schemes to the resolver/dispatcher.
    [uriHandler addHandler:[[IFDoSchemeHandler alloc] init] forScheme:@"do"];
    [uriHandler addHandler:[[IFNewScheme alloc] initWithContainer:self] forScheme:@"new"];
    [uriHandler addHandler:[[IFMakeScheme alloc] initWithContainer:self] forScheme:@"make"];
    [uriHandler addHandler:[[IFNamedSchemeHandler alloc] initWithNamed:named] forScheme:@"named"];
    // Additional configured schemes.
    IFConfiguration *dispatcherConfig = [configuration getValueAsConfiguration:@"schemes"];
    if (dispatcherConfig) {
        for (NSString *schemeName in [dispatcherConfig getValueNames]) {
            IFConfiguration *schemeConfig = [dispatcherConfig getValueAsConfiguration:schemeName];
            id handler = [self buildObjectWithConfiguration:schemeConfig identifier:schemeName];
            if ([handler conformsToProtocol:@protocol(IFSchemeHandler)]) {
                [uriHandler addHandler:handler forScheme:schemeName];
            }
        }
    }
    
    // Default local settings.
    locals = [[IFLocals alloc] initWithPrefix:@"semo"];
    NSDictionary *settings = (NSDictionary *)[configuration getValue:@"settings"];
    if (settings) {
        [locals setValues:settings forceReset:ForceResetDefaultSettings];
    }
    
    [named setObject:uriHandler forKey:@"uriHandler"];
    [named setObject:globals forKey:@"globals"];
    [named setObject:locals forKey:@"locals"];
    [named setObject:self forKey:@"container"];
    
    // Perform default container configuration.
    [super configureWith:configuration];
    
    // Any named object can be a potential action target.
    rootTargetContainer.namedTargets = named;
}

- (NSMutableDictionary *)makeDefaultGlobalModelValues:(IFConfiguration *)configuration {
    
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    float scale = [UIScreen mainScreen].scale;
    NSString *display = scale > 1.0 ? [NSString stringWithFormat:@"%f.0x", scale] : @"";
    NSDictionary *platformValues = @{
        @"name":            Platform,
        @"dispay":          display,
        @"defaultDisplay":  @"2x",
        @"full":            [NSString stringWithFormat:@"ios%@", display]
    };
    [values setObject:platformValues forKey:@"platform"];
    
    NSString *mode = [configuration getValueAsString:@"mode" defaultValue:@"LIVE"];
    DDLogInfo(@"%@: Configuration mode: %@", LogTag, mode);
    [values setObject:mode forKey:@"mode"];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *lang = nil;
    DDLogInfo(@"%@: Current locale is %@", LogTag, locale.localeIdentifier);
    
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
    DDLogInfo(@"%@: Using language %@", LogTag, lang);
    
    NSDictionary *localeValues = @{
        @"id":       [locale objectForKey:NSLocaleIdentifier],
        @"lang":     lang,
        @"variant":  [locale objectForKey:NSLocaleCountryCode]
    };
    [values setObject:localeValues forKey:@"locale"];
    [values setObject:[IFI18nMap instance] forKey:@"i18n"];
    
    return values;
}

- (UIViewController *)getRootView {
    id rootView = [named objectForKey:@"rootView"];
    if (!rootView) {
        DDLogError(@"%@: No component named 'rootView' found", LogTag);
    }
    else if ([rootView isKindOfClass:[UIView class]]) {
        // Promote UIView to a view controller.
        IFTargetContainerViewController *viewController = [[IFTargetContainerViewController alloc] initWithView:(UIView *)rootView];
        rootView = viewController;
    }
    else if (![rootView isKindOfClass:[UIViewController class]]) {
        DDLogError(@"%@: The component named 'rootView' is not an instance of UIView or UIViewController", LogTag);
        rootView = nil;
    }
    if ([rootView conformsToProtocol:@protocol(IFTargetContainer)]) {
        ((id<IFTargetContainer>)rootView).parentTargetContainer = rootTargetContainer;
    }
    return rootView;
}

#pragma mark - Overrides

- (void)configureObject:(id)object withConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier {
    [super configureObject:object withConfiguration:configuration identifier:identifier];
    // Set URI handler on any target container objects.
    if ([object conformsToProtocol:@protocol(IFTargetContainer)]) {
        ((id<IFTargetContainer>)object).uriHandler = _uriHandler;
    }
}

#pragma mark - IFActionTarget protocol

- (void)doAction:(IFDoAction *)action {
    if ([@"system-open" isEqualToString:action.name]) {
        NSURL *url = [[action parameterValue:@"url"] asURL];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Class statics

static IFAppContainer *instance;

+ (void)initialize {
    instance = [[IFAppContainer alloc] init];
    [instance addTypes:[IFCoreTypes types]];
}

+ (IFAppContainer *)getAppContainer {
    return instance;
}

+ (IFAppContainer *)bindToWindow:(UIWindow *)window {
    IFAppContainer *container = [IFAppContainer getAppContainer];
    [container loadConfiguration:@"app:config.json"];
    window.rootViewController = [container getRootView];
    window.backgroundColor = container.appBackgroundColor;
    return container;
}

@end
