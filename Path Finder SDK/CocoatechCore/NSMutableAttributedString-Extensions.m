//
//  NSMutableAttributedString-Extensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Sun Jul 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "NSMutableAttributedString-Extensions.h"

static NSURL* findURL(NSString* string);

@implementation NSMutableAttributedString (NTExtensions)

+ (NSMutableAttributedString*)string;
{
	return [[[NSMutableAttributedString alloc] init] autorelease];
}

- (void)detectURLs:(NSColor*)linkColor
{
    NSScanner*					scanner;
    NSRange						scanRange;
    NSString*					scanString;
    NSCharacterSet*				whitespaceSet;
    NSURL*						foundURL;
    NSDictionary*				linkAttr;
    
    // Create our scanner and supporting delimiting character set
    scanner = [NSScanner scannerWithString:[self string]];
    whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    // Start Scan
    while( ![scanner isAtEnd] )
    {
        // Pull out a token delimited by whitespace or new line
        [scanner scanUpToCharactersFromSet:whitespaceSet intoString:&scanString];
        scanRange.length = [scanString length];
        scanRange.location = [scanner scanLocation] - scanRange.length;
        
        // If we find a url modify the string attributes
        if(( foundURL = findURL(scanString) ))
        {
            // Apply underline style and link color
            linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                foundURL, NSLinkAttributeName,
                [NSNumber numberWithInteger:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
                linkColor, NSForegroundColorAttributeName, NULL ];
            [self addAttributes:linkAttr range:scanRange];
        }
    }
}

- (void)appendImage:(NSImage*)image;
{
    static NSUInteger unique = 0;  // Cocoa can work correctly if the the name is the same, but this may make it faster
    NSFileWrapper* fileWrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:[image TIFFRepresentation]] autorelease];

    [fileWrapper setPreferredFilename:[NSString stringWithFormat:@"icon%lu.tiff", unique++]];

    NSTextAttachment *attachment = [[[NSTextAttachment alloc] initWithFileWrapper:fileWrapper] autorelease]; 
        
    [(NSTextAttachmentCell*) [attachment attachmentCell] setImage:image];
    
    [self appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
}

+ (NSMutableAttributedString*)stringWithString:(NSString*)inString attributes:(NSDictionary*)attributes;
{
	NSMutableAttributedString* result = [[NSMutableAttributedString alloc] initWithString:inString attributes:attributes];
	
	return [result autorelease];
}

+ (NSMutableAttributedString*)stringWithURL:(NSURL*)theURL;
{
	NSMutableAttributedString *result = [[[NSMutableAttributedString alloc] init] autorelease];
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	
	[result beginEditing];
	BOOL success = [result readFromURL:theURL options:options documentAttributes:nil error:nil];
	[result endEditing];
	
	if (success)
		return result;
	
	return nil;
}	

- (void)appendString:(NSString *)string attributes:(NSDictionary *)attributes;
{
    NSAttributedString *append;
	
    append = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    [self appendAttributedString:append];
    [append release];
}

/*" Appends the given string to the receiver, using the attributes of the last character in the receiver for the new characters.  If the receiver is empty, the appended string has no attributes. "*/
- (void)appendString:(NSString *)string;
{
    NSDictionary *attributes = nil;
    NSUInteger  length = [self length];
	
    if (length)
        attributes = [self attributesAtIndex:length-1 effectiveRange:NULL];
    [self appendString:string attributes:attributes];
}

@end

NSURL* findURL(NSString* string)
{
    NSRange		theRange;
    
    // Look for ://
    theRange = [string rangeOfString:@"://"];
    if( theRange.location != NSNotFound && theRange.length != 0 )
        return [NSURL URLWithString:string];
    
    // Look for www. at start
    theRange = [string rangeOfString:@"www." options:NSCaseInsensitiveSearch];
    if( theRange.location == 0 && theRange.length == 4 )
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", string]];
    
    // Look for ftp. at start
    theRange = [string rangeOfString:@"ftp." options:NSCaseInsensitiveSearch];
    if( theRange.location == 0 && theRange.length == 4 )
        return [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", string]];
    
    // Look for gopher. at start
    theRange = [string rangeOfString:@"gopher." options:NSCaseInsensitiveSearch];
    if( theRange.location == 0 && theRange.length == 7 )
        return [NSURL URLWithString:[NSString stringWithFormat:@"gopher://%@", string]];
    
    // Look for mailto: at start
    theRange = [string rangeOfString:@"mailto:" options:NSCaseInsensitiveSearch];
    if( theRange.location == 0 && theRange.length == 7 )
        return [NSURL URLWithString:string];

    // There was no mailto, so look for a @ and if found, look for a .xxx
    theRange = [string rangeOfString:@"@"];
    if( theRange.location != NSNotFound && theRange.length != 0 )
    {
        theRange = [string rangeOfString:@"." options:NSBackwardsSearch];

        if( theRange.location != NSNotFound)
        {
            NSInteger numTrailingChars = ([string length] - NSMaxRange(theRange));
            
            if (numTrailingChars > 1 && numTrailingChars <= 4)
                return [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", string]];
        }
    }
        
    // custom words
    theRange = [string rangeOfString:@"Cocoatech" options:NSCaseInsensitiveSearch];
    if( theRange.location == 0 && theRange.length == [string length] )
        return [NSURL URLWithString:@"http://www.cocoatech.com/"];

    theRange = [string rangeOfString:@"Apple"];
    if( theRange.location == 0 && theRange.length == [string length] )
        return [NSURL URLWithString:@"http://www.apple.com/"];
    
    return nil;
}
