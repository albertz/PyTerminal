// NTLocalizedString.h

#import <Cocoa/Cocoa.h>

@interface NTLocalizedString : NSObject
{
}

+ (NSString*)localize:(NSString*)str; // default table
+ (NSString*)localize:(NSString*)str table:(NSString*)table;
+ (NSString*)localize:(NSString*)str table:(NSString*)table bundle:(NSBundle*)bundle;

+ (void)localizeWindow:(NSWindow*)window; // default table
+ (void)localizeWindow:(NSWindow*)window table:(NSString*)table;

+ (void)localizeView:(NSView*)view;
+ (void)localizeView:(NSView*)view table:(NSString*)table;

@end

@interface NTLocalizedString (Regions)

+ (BOOL)usingEnglishLocalization; // region would return "en" if YES

+ (NSString*)colon; // ":" = english, " :" = french

+ (NSString*)region;
+ (NSArray*)regions;

@end

// -----------------------------------------------------------------------------------
// filtering
// filters are used to monitor the inputs of localize
// used for the internal localization managing tools, not used by ordinary users

@protocol NTLocalizedStringFilterProtocol <NSObject>
// called for strings that have identical localization
- (void)localizedStringFilter_unlocalizedString:(NSString*)str table:(NSString*)table;
@end

@interface NTLocalizedString (Filter)
+ (void)setLocalizedStringFilter:(id<NTLocalizedStringFilterProtocol>)filter;
@end
