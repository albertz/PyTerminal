#import <Foundation/Foundation.h>

@interface NSString (Utilities)
+ (NSString*)stringWithFileSystemRepresentation:(const char*)path;
+ (NSString*)stringWithPString:(Str255)pString;
+ (id)stringWithUTF8String:(const void *)bytes length:(NSUInteger)length;
+ (id)stringWithMacOSRomanString:(const char *)nullTerminatedCString;
+ (id)stringWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;

- (void)getPString:(Str255)outString;
- (void)getUTF8String:(char*)outString maxLength:(NSInteger)maxLength;

// not for filesystem names, use fileNameWithHFSUniStr255
+ (NSString*)stringWithHFSUniStr255:(const HFSUniStr255*)hfsString;
- (void)HFSUniStr255:(HFSUniStr255*)hfsString;

// will convert : to / and / to : so if they are paths
+ (NSString*)fileNameWithHFSUniStr255:(const HFSUniStr255*)hfsString;

- (NSString*)stringByReplacing:(NSString *)value with:(NSString *)newValue;
- (NSString*)stringByReplacingValuesInArray:(NSArray *)values withValuesInArray:(NSArray *)newValues;
- (NSString*)stringByDeletingSuffix:(NSString *)suffix;
- (NSString*)stringByDeletingPrefix:(NSString *)prefix;
- (BOOL)stringContainsValueFromArray:(NSArray *)theValues;
- (BOOL)isEqualToStringCaseInsensitive:(NSString *)str;

// variants with caseSensitive option
- (BOOL)isEqualToString:(NSString *)str caseSensitive:(BOOL)caseSensitive;
- (BOOL)hasPrefix:(NSString *)str caseSensitive:(BOOL)caseSensitive;
- (BOOL)hasSuffix:(NSString *)str caseSensitive:(BOOL)caseSensitive;
- (NSString*)stringByDeletingSuffix:(NSString *)suffix caseSensitive:(BOOL)caseSensitive;
- (NSString*)stringByDeletingPrefix:(NSString *)prefix caseSensitive:(BOOL)caseSensitive;

- (NSString*)stringInStringsFileFormat;
- (NSString*)stringFromStringsFileFormat;  // reverse of above
- (NSString*)stringPairInStringsFileFormat:(NSString*)right addNewLine:(BOOL)addNewLine;

- (NSArray*)linesFromString:(NSString**)outRemainder;
- (NSString*)getFirstLine;
// notInQuotes YES if your not going to quote the string for the terminal
- (NSString*)stringWithShellCharactersEscaped:(BOOL)notInQuotes;
- (NSString*)stringWithRegularExpressionCharactersQuoted;

    // converts a POSIX path to an HFS path
- (NSString*)HFSPath;
    // converts a HFS path to a POSIX path
- (NSString*)POSIXPath;

- (NSString*)stringByTrimmingWhiteSpace;
+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
- (NSString *)stringByRemovingReturns;
- (NSString *)stringByRemovingCharactersInCharacterSet:(NSCharacterSet *)removeSet;

- (NSString *)stringByRemovingPrefix:(NSString *)prefix;
- (NSString *)stringByRemovingSuffix:(NSString *)suffix;

// converts a POSIX path to a Windows path
- (NSString*)windowsPath;

- (BOOL)isEndOfWordAtIndex:(NSUInteger)index;
- (BOOL)isStartOfWordAtIndex:(NSUInteger)index;

- (NSString*)stringByTruncatingToLength:(NSUInteger)length;

- (NSString*)stringByDecryptingString;
- (NSString*)stringByEncryptingString;

- (BOOL)FSRef:(FSRef*)fsRef createFileIfNecessary:(BOOL)createFile;
- (BOOL)FSSpec:(FSSpec*)fsSpec createFileIfNecessary:(BOOL)createFile;

- (NSString*)URLEncodedString;

// excludes extensions with spaces
- (NSString*)strictPathExtension;
- (NSString*)strictStringByDeletingPathExtension;

- (NSString*)stringByDeletingPercentEscapes;

- (NSComparisonResult)filenameCompareWithString:(NSString *)string;

- (NSString*)slashToColon;
- (NSString*)colonToSlash;

// a unique string
+ (NSString*)unique;

	// Split on slashes and chop out '.' and '..' correctly.
- (NSString *)normalizedPath;

- (NSData*)nullTerminatedDataUsingEncoding:(NSStringEncoding)theEncoding;

@end

// =======================================================================================

@interface NSMutableString(Utilities)
- (void)replace:(NSString *)value with:(NSString *)newValue;
- (void)appendChar:(unichar)aCharacter;
@end;

