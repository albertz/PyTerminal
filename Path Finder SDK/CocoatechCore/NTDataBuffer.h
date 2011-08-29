//
//  NTDataBuffer.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/10/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <math.h>
#import <stdio.h>

typedef struct {
    /*" The full contents of the buffer "*/
    NSMutableData  *data;
    
    /*" The current pointer of the data object "*/
    unsigned char         *buffer;
    
    /*" The current start of the writable area "*/
    unsigned char         *writeStart;
    
    /*" The end of the buffer (buffer + bufferSize) "*/
    unsigned char         *bufferEnd;
    
    /*" The endianness in which to write host data types "*/
    CFByteOrder     byteOrder;
} NTDataBuffer;

static inline void
NTDataBufferInit(NTDataBuffer *dataBuffer)
{
    dataBuffer->data = [[NSMutableData alloc] init];
    dataBuffer->buffer = NULL;
    dataBuffer->writeStart = NULL;
    dataBuffer->bufferEnd = NULL;
    dataBuffer->byteOrder = CFByteOrderUnknown;
}

static inline void
NTDataBufferRelease(NTDataBuffer *dataBuffer)
{
    [dataBuffer->data release];
    dataBuffer->data = nil;
    dataBuffer->buffer = NULL;
    dataBuffer->writeStart = NULL;
    dataBuffer->bufferEnd = NULL;
    dataBuffer->byteOrder = CFByteOrderUnknown;
}

static inline size_t
NTDataBufferSpaceOccupied(NTDataBuffer *dataBuffer)
{
    return dataBuffer->writeStart - dataBuffer->buffer;
}

static inline size_t
NTDataBufferSpaceAvailable(NTDataBuffer *dataBuffer)
{
    return dataBuffer->bufferEnd - dataBuffer->writeStart;
}

static inline size_t
NTDataBufferSpaceCapacity(NTDataBuffer *dataBuffer)
{
    return dataBuffer->bufferEnd - dataBuffer->buffer;
}

static inline void
NTDataBufferSetCapacity(NTDataBuffer *dataBuffer, size_t capacity)
{
    size_t occupied;
	
    occupied = NTDataBufferSpaceOccupied(dataBuffer);
    [dataBuffer->data setLength: capacity];
    dataBuffer->buffer = (unsigned char *)[dataBuffer->data mutableBytes];
    dataBuffer->writeStart = dataBuffer->buffer + occupied;
    dataBuffer->bufferEnd  = dataBuffer->buffer + capacity;
}

static inline void
NTDataBufferSizeToFit(NTDataBuffer *dataBuffer)
{
    NTDataBufferSetCapacity(dataBuffer, NTDataBufferSpaceOccupied(dataBuffer));
}

static inline NSData *
NTDataBufferData(NTDataBuffer *dataBuffer)
{
    // For backwards compatibility (and just doing what the caller expects)
    // this must size the buffer to the expected size.
    NTDataBufferSizeToFit(dataBuffer);
    return dataBuffer->data;
}

// Backwards compatibility
static inline void
NTDataBufferFlush(NTDataBuffer *dataBuffer)
{
    NTDataBufferSizeToFit(dataBuffer);
}

static inline unsigned char *
NTDataBufferGetPointer(NTDataBuffer *dataBuffer, size_t spaceNeeded)
{
    size_t newSize;
    size_t occupied;
    
    if (NTDataBufferSpaceAvailable(dataBuffer) >= spaceNeeded)
        return dataBuffer->writeStart;
	
    // Otherwise, we have to grow the internal data and reset all our pointers
    occupied = NTDataBufferSpaceOccupied(dataBuffer);
    newSize = 2 * NTDataBufferSpaceCapacity(dataBuffer);
    if (newSize < occupied + spaceNeeded)
        newSize = 2 * (occupied + spaceNeeded);
	
    NTDataBufferSetCapacity(dataBuffer, newSize);        
    
    return dataBuffer->writeStart;
}

static inline void
NTDataBufferDidAppend(NTDataBuffer *dataBuffer, size_t spaceUsed)
{    
    dataBuffer->writeStart += spaceUsed;
}

static inline char
NTDataBufferHexCharacterForDigit(int digit)
{
    if (digit < 10)
		return digit + '0';
    else
		return digit + 'a' - 10;
}

static inline void
NTDataBufferAppendByte(NTDataBuffer *dataBuffer, unsigned char aByte)
{
    unsigned char *ptr;
    
    ptr = NTDataBufferGetPointer(dataBuffer, sizeof(unsigned char));
    *ptr = aByte;
    NTDataBufferDidAppend(dataBuffer, sizeof(unsigned char));
}

static inline void
NTDataBufferAppendHexForByte(NTDataBuffer *dataBuffer, unsigned char aByte)
{
    unsigned char *ptr;
    
    ptr = NTDataBufferGetPointer(dataBuffer, 2 *sizeof(unsigned char));
    ptr[0] = NTDataBufferHexCharacterForDigit((aByte & 0xf0) >> 4);
    ptr[1] = NTDataBufferHexCharacterForDigit(aByte & 0x0f);
    NTDataBufferDidAppend(dataBuffer, 2 * sizeof(unsigned char));
}

static inline void
NTDataBufferAppendCString(NTDataBuffer *dataBuffer, const char *str)
{
    const char *characterPtr;
    
    for (characterPtr = str; *characterPtr; characterPtr++)
		NTDataBufferAppendByte(dataBuffer, *characterPtr);
}

static inline void
NTDataBufferAppendBytes(NTDataBuffer *dataBuffer, const unsigned char *bytes, unsigned int length)
{
    unsigned char *ptr;
    unsigned int byteIndex;
    
    ptr = NTDataBufferGetPointer(dataBuffer, length);
	
    // The compiler is smart enough to optimize this
    for (byteIndex = 0; byteIndex < length; byteIndex++)
        ptr[byteIndex] = bytes[byteIndex];
    
    NTDataBufferDidAppend(dataBuffer, length);
}


#define NTDataBufferSwapBytes(value, swapType)				\
switch (dataBuffer->byteOrder) {					\
case CFByteOrderUnknown:      					\
break;	   						\
case CFByteOrderLittleEndian:      					\
value = NSSwapHost ## swapType ## ToLittle(value);		\
break;							\
case CFByteOrderBigEndian:						\
value = NSSwapHost ## swapType ## ToBig(value);		\
break;							\
}

#define NTDataBufferAppendOfType(cType, nameType, swapType)	 	\
static inline void NTDataBufferAppend ## nameType      			\
(NTDataBuffer *dataBuffer, cType value)				\
{									\
NTDataBufferSwapBytes(value, swapType);    				\
NTDataBufferAppendBytes(dataBuffer, (unsigned char *)&value, sizeof(cType));	\
}

NTDataBufferAppendOfType(long int, LongInt, Long)
NTDataBufferAppendOfType(short int, ShortInt, Short)
NTDataBufferAppendOfType(unichar, Unichar, Short)
NTDataBufferAppendOfType(long long int, LongLongInt, LongLong)

#undef NTDataBufferAppendOfType
#undef NTDataBufferSwapBytes

static inline void NTDataBufferAppendFloat(NTDataBuffer *dataBuffer, float value)
{
    NSSwappedFloat swappedValue;
	
    switch (dataBuffer->byteOrder) {
        case CFByteOrderUnknown:
            swappedValue = NSConvertHostFloatToSwapped(value);
            break;
        case CFByteOrderLittleEndian:
            swappedValue = NSSwapHostFloatToLittle(value);
            break;
        case CFByteOrderBigEndian:
            swappedValue = NSSwapHostFloatToBig(value);
            break;
    }
    NTDataBufferAppendBytes(dataBuffer, (unsigned char *)&swappedValue, sizeof(float));
}

static inline void NTDataBufferAppendDouble(NTDataBuffer *dataBuffer, double value)
{
    NSSwappedDouble swappedValue;
	
    switch (dataBuffer->byteOrder) {
        case CFByteOrderUnknown:
            swappedValue = NSConvertHostDoubleToSwapped(value);
            break;
        case CFByteOrderLittleEndian:
            swappedValue = NSSwapHostDoubleToLittle(value);
            break;
        case CFByteOrderBigEndian:
            swappedValue = NSSwapHostDoubleToBig(value);
            break;
    }
    NTDataBufferAppendBytes(dataBuffer, (const unsigned char *)&swappedValue, sizeof(double));
}

#define NT_COMPRESSED_INT_BITS_OF_DATA    7
#define NT_COMPRESSED_INT_CONTINUE_MASK   0x80
#define NT_COMPRESSED_INT_DATA_MASK       0x7f

static inline void NTDataBufferAppendCompressedLongInt(NTDataBuffer *dataBuffer, unsigned long int value)
{
    do {
        unsigned char sevenBitsPlusContinueFlag = 0;
		
        sevenBitsPlusContinueFlag = value & NT_COMPRESSED_INT_DATA_MASK;
        value >>= NT_COMPRESSED_INT_BITS_OF_DATA;
        if (value != 0)
            sevenBitsPlusContinueFlag |= NT_COMPRESSED_INT_CONTINUE_MASK;
        NTDataBufferAppendByte(dataBuffer, sevenBitsPlusContinueFlag);
    } while (value != 0);
}

static inline void NTDataBufferAppendCompressedLongLongInt(NTDataBuffer *dataBuffer, unsigned long long int value)
{
    do {
        unsigned char sevenBitsPlusContinueFlag = 0;
		
        sevenBitsPlusContinueFlag = value & NT_COMPRESSED_INT_DATA_MASK;
        value >>= NT_COMPRESSED_INT_BITS_OF_DATA;
        if (value != 0)
            sevenBitsPlusContinueFlag |= NT_COMPRESSED_INT_CONTINUE_MASK;
        NTDataBufferAppendByte(dataBuffer, sevenBitsPlusContinueFlag);
    } while (value != 0);
}

static inline void
NTDataBufferAppendHexWithReturnsForBytes(NTDataBuffer *dataBuffer, const unsigned char *bytes, unsigned int length)
{
    unsigned int byteIndex;
    
    byteIndex = 0;
    while (byteIndex < length) {
		NTDataBufferAppendHexForByte(dataBuffer, bytes[byteIndex]);
		byteIndex++;
		if ((byteIndex % 40) == 0)
			NTDataBufferAppendByte(dataBuffer, '\n');
    }
}


static inline void
NTDataBufferAppendInteger(NTDataBuffer *dataBuffer, int integer)
{
    int divisor;
    
    if (integer < 0) {
		integer *= -1;
		NTDataBufferAppendByte(dataBuffer, '-');
    }
    
    divisor = (int)log10((double)integer);
    if (divisor < 0)
		divisor = 0;
    divisor = (int)pow(10.0, (double)divisor);
    while (1) {
		NTDataBufferAppendByte(dataBuffer, (integer / divisor) + '0');
		if (divisor <= 1)
			break;
		integer %= divisor;
		divisor /= 10;
    }
}

static inline void
NTDataBufferAppendData(NTDataBuffer *dataBuffer, NSData *data)
{
    NTDataBufferAppendBytes(dataBuffer, (const unsigned char *)[data bytes], [data length]);
}

static inline void
NTDataBufferAppendHexWithReturnsForData(NTDataBuffer *dataBuffer, NSData *data)
{
    NTDataBufferAppendHexWithReturnsForBytes(dataBuffer, (const unsigned char *)[data bytes], [data length]);
}

static inline void
NTDataBufferAppendString(NTDataBuffer *dataBuffer, CFStringRef string, CFStringEncoding encoding)
{
    unsigned char *ptr;
    CFIndex characterCount, usedBufLen;
        
    characterCount = CFStringGetLength(string);
	
    // In UTF-8, characters can take up to 4 bytes.  We'll assume the worst case here.
    ptr = NTDataBufferGetPointer(dataBuffer, 4 * characterCount);
	
    CFIndex charactersWritten = CFStringGetBytes(string, CFRangeMake(0, characterCount), encoding, 0/*lossByte*/, false/*isExternalRepresentation*/, ptr, 4 * characterCount, &usedBufLen);
    if (charactersWritten != characterCount) {
        [NSException raise: NSInternalInconsistencyException
                    format: @"NTDataBufferAppendString was supposed to write %d characters but only wrote %d", characterCount, charactersWritten];
    }
    
    NTDataBufferDidAppend(dataBuffer, usedBufLen);
}

static inline void
NTDataBufferAppendBytecountedUTF8String(NTDataBuffer *dataBuffer, NTDataBuffer *scratchBuffer, CFStringRef string)
{
    UInt8 *bytePointer;
    CFIndex charactersWritten, stringLength, maximumLength, stringLengthInBuffer;
	
    stringLength = CFStringGetLength(string);
    maximumLength = 4 * stringLength; // In UTF-8, characters can take up to 4 bytes.  We'll assume the worst case here.
    bytePointer = NTDataBufferGetPointer(scratchBuffer, maximumLength);
    charactersWritten = CFStringGetBytes(string, CFRangeMake(0, stringLength), kCFStringEncodingUTF8, 0/*lossByte*/, false/*isExternalRepresentation*/, bytePointer, maximumLength, &stringLengthInBuffer);
    if (charactersWritten != stringLength)
        [NSException raise: NSInternalInconsistencyException
                    format: @"NTDataBufferAppendBytecountedUTF8String was supposed to write %d characters but only wrote %d", stringLength, charactersWritten];
    NTDataBufferAppendCompressedLongInt(dataBuffer, stringLengthInBuffer);
    NTDataBufferAppendBytes(dataBuffer, bytePointer, stringLengthInBuffer);
}

static inline void
NTDataBufferAppendUnicodeString(NTDataBuffer *dataBuffer, CFStringRef string)
{
    unsigned char       *ptr;
    CFIndex       characterCount, usedBufLen;
    
    characterCount = CFStringGetLength(string);
    ptr = NTDataBufferGetPointer(dataBuffer, sizeof(unichar) * characterCount);
    CFIndex charactersWritten = CFStringGetBytes(string, CFRangeMake(0, characterCount), kCFStringEncodingUnicode, 0/*lossByte*/, false/*isExternalRepresentation*/, ptr, sizeof(unichar) * characterCount, &usedBufLen);
    if (charactersWritten != characterCount) {
        [NSException raise: NSInternalInconsistencyException
                    format: @"NTDataBufferAppendUnicodeString was supposed to write %d characters but only wrote %d", characterCount, charactersWritten];
    }
	
    NTDataBufferDidAppend(dataBuffer, usedBufLen);
}

static inline void
NTDataBufferAppendUnicodeByteOrderMark(NTDataBuffer *dataBuffer)
{
    unichar BOM = 0xFEFF;  /* zero width non breaking space a.k.a. byte-order mark */
    
    // We don't use NTDataBufferAppendUnichar() here because that will byteswap the value, and the point of this routine is to indicate the byteorder of a buffer we're writing to with NTDataBufferAppendUnicodeString(), which does *not* byteswap.
    NTDataBufferAppendBytes(dataBuffer, (const unsigned char *)&BOM, sizeof(BOM));
}

//
// XML Support
//

extern void NTDataBufferAppendXMLQuotedString(NTDataBuffer *dataBuffer, CFStringRef string);

