//
//  PyTerminalView.h
//  PyTerminal
//
//  Created by Albert Zeyer on 31.08.11.
//  Copyright 2011 Albert Zeyer. All rights reserved.
//

#import <iTerm/iTerm.h>

@interface PyTerminalTask : NSObject
{
	@public int TTY_SLAVE;	
}
@end

@interface PyTerminalView : ITTerminalView
- (void)addNewSession:(NSDictionary *)addressbookEntry
		  withCommand:(NSString *)command
			  withURL:(NSString*)url;
- (void)_runPython:(PyTerminalTask *)task;
@end
