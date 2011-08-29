//
//  BGHUDStepperCell.h
//  BGHUDAppKit
//
//  Created by BinaryGod on 4/6/09.
//  Copyright 2009 none. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BGThemeManager.h"

@interface BGHUDStepperCell : NSStepperCell {

	NSString *themeKey;
	NSInteger topButtonFlag;
	NSInteger bottomButtonFlag;
}

@property (retain) NSString *themeKey;

@end
