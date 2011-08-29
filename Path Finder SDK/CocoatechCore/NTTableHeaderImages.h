//
//  NTTableHeaderImages.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NTSingletonObject.h"

@interface NTTableHeaderImages : NTSingletonObject {
}

- (CGFloat)height;

- (void)drawInFrame:(NSRect)frame 
		highlighted:(BOOL)highlighted
		   selected:(BOOL)selected
			flipped:(BOOL)flipped;

@end
