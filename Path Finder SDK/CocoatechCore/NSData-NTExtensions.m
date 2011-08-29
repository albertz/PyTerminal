//
//  NSData-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/5/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSData-NTExtensions.h"
#import "NSString-Utilities.h"
#import "NTDataBuffer.h"
#import <zlib.h>

@implementation NSData (NTExtensions)

- (NSData *)inflate
{
	if ([self length] == 0) 
		return self;
	
	unsigned full_length = [self length];
	unsigned half_length = [self length] / 2;
	
	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
	BOOL done = NO;
	int status;
	
	z_stream strm;
	strm.next_in = (Bytef *)[self bytes];
	strm.avail_in = [self length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit (&strm) != Z_OK)
		return nil;
	
	while (!done)
	{
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy: half_length];
		
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
		
		// Inflate another chunk.
		status = inflate (&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) 
			done = YES;
		
		else if (status != Z_OK) 
			break;
	}
	
	if (inflateEnd (&strm) != Z_OK) 
		return nil;
	
	// Set real length.
	if (done)
	{
		[decompressed setLength: strm.total_out];
		return [NSData dataWithData: decompressed];
	}
	
	return nil;
}

+ (NSData*)inflateFile:(NSString*)path;
{
	NSMutableData *mData = [NSMutableData data];
	
	// inflate the focker
	gzFile file =  gzopen([path UTF8String], "rb");
	if (file)
	{
		char *buf = malloc(16*1024);
		int bytesRead;
		
		for (;;)
		{
			bytesRead = gzread(file, buf, 4096);
			
			if (bytesRead>0)
				[mData appendBytes:buf length:bytesRead];
			else
				break;
		}
		
		free(buf);
		gzclose(file);
	}
		
	return mData;
}

+ (NSData*)dataWithCarbonHandle:(Handle)handle;
{
    NSData *result;
	
    HLock(handle);
    result = [[NSData alloc] initWithBytes:*handle length:GetHandleSize(handle)];
    HUnlock(handle);
	
    return [result autorelease];
}

- (Handle)carbonHandle;
{
    Handle result = NewHandle([self length]);
    HLock(result);
    [self getBytes:*result];
    HUnlock(result);
	
    return result;
}

static unsigned sEncryptionKey = 0xCA35AC53;
static unsigned sEncryptionKeyLength = 4;

// NOTE: files may be saved in this format, don't change formula until you verify this
- (NSData*)encrypt;
{
	NSMutableData* mutableData = [NSMutableData dataWithData:self];
	unsigned char* ptr = [mutableData mutableBytes];
	unsigned char* keyPtr=(unsigned char*)&sEncryptionKey;
	unsigned keyIndex=0;
	
	unsigned i, cnt = [mutableData length];
	for (i=0;i<cnt;i++)
	{
		ptr[i] ^= keyPtr[keyIndex++]; // xor the bytes
		
		if (keyIndex >= sEncryptionKeyLength)
			keyIndex = 0;
	}
	
	return [NSData dataWithData:mutableData];
}

- (NSData*)decrypt;
{
	return [self encrypt]; // reverse is a decrypt
}

//
// Base-64 (RFC-1521) support.  The following is based on mpack-1.5 (ftp://ftp.andrew.cmu.edu/pub/mpack/)
//

#define XX 127
static char index_64[256] = {
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,62, XX,XX,XX,63,
52,53,54,55, 56,57,58,59, 60,61,XX,XX, XX,XX,XX,XX,
XX, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,
15,16,17,18, 19,20,21,22, 23,24,25,XX, XX,XX,XX,XX,
XX,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,
41,42,43,44, 45,46,47,48, 49,50,51,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
};
#define CHAR64(c) (index_64[(unsigned char)(c)])

#define BASE64_GETC (length > 0 ? (length--, bytes++, (unsigned int)(bytes[-1])) : (unsigned int)EOF)
#define BASE64_PUTC(c) NTDataBufferAppendByte(buffer, (c))

+ (id)dataWithBase64String:(NSString *)base64String;
{
    return [[[self alloc] initWithBase64String:base64String] autorelease];
}

- initWithBase64String:(NSString *)base64String;
{
    NSData *base64Data;
    const char *bytes;
    unsigned int length;
    NTDataBuffer dataBuffer, *buffer;
    NSData *decodedData;
    NSData *returnValue;
    BOOL suppressCR = NO;
    unsigned int c1, c2, c3, c4;
    int DataDone = 0;
    char buf[3];
		
    buffer = &dataBuffer;
    NTDataBufferInit(buffer);
	
    base64Data = [base64String dataUsingEncoding:NSASCIIStringEncoding];
    bytes = [base64Data bytes];
    length = [base64Data length];
	
    while ((c1 = BASE64_GETC) != (unsigned int)EOF) {
        if (c1 != '=' && CHAR64(c1) == XX)
            continue;
        if (DataDone)
            continue;
        
        do {
            c2 = BASE64_GETC;
        } while (c2 != (unsigned int)EOF && c2 != '=' && CHAR64(c2) == XX);
        do {
            c3 = BASE64_GETC;
        } while (c3 != (unsigned int)EOF && c3 != '=' && CHAR64(c3) == XX);
        do {
            c4 = BASE64_GETC;
        } while (c4 != (unsigned int)EOF && c4 != '=' && CHAR64(c4) == XX);
        if (c2 == (unsigned int)EOF || c3 == (unsigned int)EOF || c4 == (unsigned int)EOF) {
            [NSException raise:@"Base64Error" format:@"Premature end of Base64 string"];
            break;
        }
        if (c1 == '=' || c2 == '=') {
            DataDone=1;
            continue;
        }
        c1 = CHAR64(c1);
        c2 = CHAR64(c2);
        buf[0] = ((c1<<2) | ((c2&0x30)>>4));
        if (!suppressCR || buf[0] != '\r') BASE64_PUTC(buf[0]);
        if (c3 == '=') {
            DataDone = 1;
        } else {
            c3 = CHAR64(c3);
            buf[1] = (((c2&0x0F) << 4) | ((c3&0x3C) >> 2));
            if (!suppressCR || buf[1] != '\r') BASE64_PUTC(buf[1]);
            if (c4 == '=') {
                DataDone = 1;
            } else {
                c4 = CHAR64(c4);
                buf[2] = (((c3&0x03) << 6) | c4);
                if (!suppressCR || buf[2] != '\r') BASE64_PUTC(buf[2]);
            }
        }
    }
	
    decodedData = [NTDataBufferData(buffer) retain];
    NTDataBufferRelease(buffer);
	
    returnValue = [self initWithData:decodedData];
    [decodedData release];
	
    return returnValue;
}

static char basis_64[] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static inline void output64chunk(int c1, int c2, int c3, int pads, NTDataBuffer *buffer)
{
    BASE64_PUTC(basis_64[c1>>2]);
    BASE64_PUTC(basis_64[((c1 & 0x3)<< 4) | ((c2 & 0xF0) >> 4)]);
    if (pads == 2) {
        BASE64_PUTC('=');
        BASE64_PUTC('=');
    } else if (pads) {
        BASE64_PUTC(basis_64[((c2 & 0xF) << 2) | ((c3 & 0xC0) >>6)]);
        BASE64_PUTC('=');
    } else {
        BASE64_PUTC(basis_64[((c2 & 0xF) << 2) | ((c3 & 0xC0) >>6)]);
        BASE64_PUTC(basis_64[c3 & 0x3F]);
    }
}

- (NSString *)base64String;
{
    NSString *string;
    NSData *data;
    const unsigned char *bytes;
    unsigned int length;
    NTDataBuffer dataBuffer, *buffer;
    unsigned int c1, c2, c3;
	
    buffer = &dataBuffer;
    NTDataBufferInit(buffer);
	
    bytes = [self bytes];
    length = [self length];
	
    while ((c1 = BASE64_GETC) != (unsigned int)EOF) {
        c2 = BASE64_GETC;
        if (c2 == (unsigned int)EOF) {
            output64chunk(c1, 0, 0, 2, buffer);
        } else {
            c3 = BASE64_GETC;
            if (c3 == (unsigned int)EOF) {
                output64chunk(c1, c2, 0, 1, buffer);
            } else {
                output64chunk(c1, c2, c3, 0, buffer);
            }
        }
    }
	
    data = NTDataBufferData(&dataBuffer);
    string = [NSString stringWithData:data encoding:NSASCIIStringEncoding];
    NTDataBufferRelease(&dataBuffer);
	
    return string;
}


@end
