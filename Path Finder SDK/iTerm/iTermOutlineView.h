//
//  iTermOutlineView.h
//  iTerm
//
//  Created by Tianming Yang on 10/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface iTermOutlineView : NSOutlineView {
	NSLock *_lock;
}

- (id)init;
- (void)reloadData;
- (void)dealloc;

@end
