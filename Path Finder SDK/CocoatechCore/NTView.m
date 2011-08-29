//
//  NTView.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/3/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "NTView.h"

@interface NTView (Private)
- (void)sendFrameDidChange;
- (void)sendFrameDidChangeNotification;
- (void)autoresizeSubview;
@end

@implementation NTView

- (void)commonNTViewInit;
{
	[self setAutoresizesSubviews:NO];
	[self setFrameDidChangeEnabled:YES];
	
	// turn off this built in bullshit
	if ([self postsFrameChangedNotifications])
		[self setPostsFrameChangedNotifications:NO];
	
	if ([self postsBoundsChangedNotifications])
		[self setPostsBoundsChangedNotifications:NO];
}	

- (id)initWithFrame:(NSRect)frame;
{
	self = [super initWithFrame:frame];
	
	[self commonNTViewInit];
	
	return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder;
{
	self = [super initWithCoder:aDecoder];
	
	[self commonNTViewInit];
	
	return self;
}

- (void)addSubview:(NSView*)subview;
{
	[super addSubview:subview];
	
	[self autoresizeSubview];
}

- (void)setFrameDidChangeEnabled:(BOOL)set;
{
    _frameDidChangeEnabled = set;
}

- (BOOL)frameDidChangeEnabled;
{
    return _frameDidChangeEnabled;
}

- (void)setAutomaticallyResizeSubviewToFit:(BOOL)set;
{
	_automaticallyResizeSubviewToFit = set;
	
	[self autoresizeSubview];
}

- (BOOL)automaticallyResizeSubviewToFit;
{
	return _automaticallyResizeSubviewToFit;
}

// subclasses can override frameDidChange to respond to frame changes rather than registering for NSViewFrameDidChangeNotification
- (void)frameDidChange;
{
	[self autoresizeSubview];
}

- (NSRect)contentBounds;
{
	return [self bounds];
}

- (void)setPostsFrameDidChangeNotification:(BOOL)set;
{
	_postsFrameDidChangeNotifications = set;
}

- (BOOL)postsFrameDidChangeNotification;
{
	return _postsFrameDidChangeNotifications;
}

// default is 0,0 - the amount to inset any view that we are autoresizing (-1, -1 to hide a frame for example)
- (void)setAutomaticResizeInset:(NSSize)inset;
{
	_autoresizeInset = inset;
	
	[self autoresizeSubview];
}

- (NSSize)automaticResizeInset
{
	return _autoresizeInset;
}

//---------------------------------------------------------- 
//  automaticResizeSizeAdjustment 
//---------------------------------------------------------- 
- (NSSize)automaticResizeSizeAdjustment
{
    return mv_automaticResizeSizeAdjustment;
}

- (void)setAutomaticResizeSizeAdjustment:(NSSize)theAutomaticResizeSizeAdjustment
{
    mv_automaticResizeSizeAdjustment = theAutomaticResizeSizeAdjustment;
}

//---------------------------------------------------------- 
//  automaticResizeOriginAdjustment 
//---------------------------------------------------------- 
- (NSPoint)automaticResizeOriginAdjustment
{
    return mv_automaticResizeOriginAdjustment;
}

- (void)setAutomaticResizeOriginAdjustment:(NSPoint)theAutomaticResizeOriginAdjustment
{
    mv_automaticResizeOriginAdjustment = theAutomaticResizeOriginAdjustment;
}

@end

@implementation NTView (PatchPointsForFrameDidChange)

- (void)setFrameOrigin:(NSPoint)newOrigin;
{
    // first compare with old value to make sure we need to call super at all
    if (NSEqualPoints(newOrigin, [self frame].origin))
        return;
        
    if (_frameDidChangeEnabled)
    {        
        _callDepth++;
        
        // we don't want an exception to get our counts out of sync
        NS_DURING
            [super setFrameOrigin:newOrigin];
        NS_HANDLER;
        NS_ENDHANDLER;
        
        _callDepth--;
        
        if (_callDepth == 0)
            [self sendFrameDidChange];
    }
    else
        [super setFrameOrigin:newOrigin];
}

- (void)setFrameSize:(NSSize)newSize;
{    
    // first compare with old value to make sure we need to call super at all
    if (NSEqualSizes(newSize, [self frame].size))
        return;
        
    if (_frameDidChangeEnabled)
    {
        _callDepth++;
        
        // we don't want an exception to get our counts out of sync
        NS_DURING
            [super setFrameSize:newSize];
        NS_HANDLER;
        NS_ENDHANDLER;
                
        _callDepth--;
        
        if (_callDepth == 0)
            [self sendFrameDidChange];
    }
    else
        [super setFrameSize:newSize];
}

- (void)setFrame:(NSRect)frameRect;
{    
    // first compare with old value to make sure we need to call super at all
    if (NSEqualRects(frameRect, [self frame]))
        return;
        
    if (_frameDidChangeEnabled)
    {
        _callDepth++;
        
        // we don't want an exception to get our counts out of sync
        NS_DURING
            [super setFrame:frameRect];
        NS_HANDLER;
        NS_ENDHANDLER;
                
        _callDepth--;
        
        if (_callDepth == 0)
            [self sendFrameDidChange];
    }
    else
        [super setFrame:frameRect];
}

- (void)setFrameRotation:(CGFloat)angle;
{    
    // first compare with old value to make sure we need to call super at all
    if (angle == [self frameRotation])
        return;
        
    if (_frameDidChangeEnabled)
    {
        _callDepth++;
                
        // we don't want an exception to get our counts out of sync
        NS_DURING
            [super setFrameRotation:angle];
        NS_HANDLER;
        NS_ENDHANDLER;
        
        _callDepth--;
        
        if (_callDepth == 0)
            [self sendFrameDidChange];
    }
    else
        [super setFrameRotation:angle];
}

@end

@implementation NTView (Private)

- (void)sendFrameDidChange;
{    
    if (!_inFrameChanged)
    {
        _inFrameChanged = YES;
		
		// catch any exceptions so our _inFrameChanged flag doesn't get out of sync
		NS_DURING
			[self frameDidChange];
			[self sendFrameDidChangeNotification];
		NS_HANDLER;
		NS_ENDHANDLER;
		
		_inFrameChanged = NO;
    }
}

- (void)sendFrameDidChangeNotification;
{
	if (_postsFrameDidChangeNotifications)
		[[NSNotificationCenter defaultCenter] postNotificationName:NTViewFrameDidChangeNotification object:self];
}

- (void)autoresizeSubview;
{
	if (_automaticallyResizeSubviewToFit)
	{
		// by default, if a single view, it keeps that view set to the content bounds
		NSArray *views = [self subviews];
		
		if ([views count] == 1)
		{
			NSSize inset = [self automaticResizeInset];
			NSRect frame = NSInsetRect([self contentBounds], inset.width, inset.height);
			
			frame.size.width += [self automaticResizeSizeAdjustment].width;
			frame.size.height += [self automaticResizeSizeAdjustment].height;
			frame.origin.x += [self automaticResizeOriginAdjustment].x;
			frame.origin.y += [self automaticResizeOriginAdjustment].y;

			[[views objectAtIndex:0] setFrame:frame];
		}
	}	
}

@end

