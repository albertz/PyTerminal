//
//  NTColorSet.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// NSColor objects
#define kNTCS_text @"NTCS_text"
#define kNTCS_unselectedText @"NTCS_unselectedText"
#define kNTCS_disabledText @"kNTCS_disabledText"

#define kNTCS_mouseOverText @"NTCS_mouseOverText"
#define kNTCS_mouseOverBackground @"NTCS_mouseOverBackground"
#define kNTCS_mouseOverControl @"NTCS_mouseOverControl"

#define kNTCS_frame @"NTCS_frame"
#define kNTCS_frame_dimmed @"NTCS_frame_dimmed"

#define kNTCS_whiteAccent @"NTCS_whiteAccent"
#define kNTCS_lightWhiteAccent @"NTCS_lightWhiteAccent"

#define kNTCS_blackAccent @"NTCS_blackAccent"
#define kNTCS_blackAccent_dimmed @"NTCS_blackAccent_dimmed"

// plain colors
#define kNTCS_black @"NTCS_black"
#define kNTCS_white @"NTCS_white"

#define kNTCS_blackImage @"NTCS_blackImage"

@interface NTColorSet : NSObject
{
	NSMutableDictionary *mColors;
}

- (NSColor*)colorForKey:(NSString*)key;
- (void)setColor:(NSColor*)color forKey:(NSString*)key;

- (NSColor*)frameColor:(BOOL)dimControls;
- (NSColor*)blackAccentColor:(BOOL)dimControls;

@end

@interface NTColorSet (NTStandardColorSets)
+ (NTColorSet*)standardSet;
@end

