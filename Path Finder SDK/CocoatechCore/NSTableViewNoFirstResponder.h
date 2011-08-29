/* NSTableViewNoFirstResponder */

#import <Cocoa/Cocoa.h>

@interface NSTableViewNoFirstResponder : NSTableView
{
}

@end

// subclass window and implement this if you want
@interface NSObject (NSTableViewNoFirstResponderWindowAdditions)
- (void)setFakeFirstResponder:(NSResponder*)responder;
@end
