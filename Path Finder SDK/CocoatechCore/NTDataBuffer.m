//
//  NTDataBuffer.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/10/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTDataBuffer.h"

static inline const unsigned char *
_NTDataBufferGetXMLStringPointer(CFStringRef string)
{
    const unsigned char *ptr;
    
    if ((ptr = (const unsigned char *)CFStringGetCStringPtr(string, kCFStringEncodingMacRoman)))
        return ptr;
	//    fprintf(stderr, "Is not MacRoman/CString\n");
    
    if ((ptr = (const unsigned char *)CFStringGetPascalStringPtr(string, kCFStringEncodingMacRoman)))
        return ptr + 1;
	//    fprintf(stderr, "Is not MacRoman/Pascal\n");
    
    if ((ptr = (const unsigned char *)CFStringGetCStringPtr(string, kCFStringEncodingASCII)))
        return ptr;
	//    fprintf(stderr, "Is not ASCII/CString\n");
    
    if ((ptr = (const unsigned char *)CFStringGetPascalStringPtr(string, kCFStringEncodingASCII)))
        return ptr + 1;
	//    fprintf(stderr, "Is not ASCII/Pascal\n");
    
    return NULL;
}

void NTDataBufferAppendXMLQuotedString(NTDataBuffer *dataBuffer, CFStringRef string)
{
    const unsigned char *source;
    unsigned char *dest, *ptr;
    unsigned int characterIndex, characterCount;
        
    characterCount = CFStringGetLength(string);
	
    // If everything is quoted, we could end up with N * characterCount bytes
    // where N = MAX(MaxUTF8CharacterLength, MaxEntityLength).
    dest = NTDataBufferGetPointer(dataBuffer, sizeof("&#xffff;") * characterCount);
	
    source = _NTDataBufferGetXMLStringPointer(string);
    if (source) {
        ptr = dest;
        for (characterIndex = 0; characterIndex < characterCount; characterIndex++, source++) {
            unsigned char c;
            
            switch ((c = *source)) {
                case '<':
                    *ptr++ = '&';
                    *ptr++ = '#';
                    *ptr++ = '6';
                    *ptr++ = '0';
                    *ptr++ = ';';
                    break;
                case '>':
                    *ptr++ = '&';
                    *ptr++ = '#';
                    *ptr++ = '6';
                    *ptr++ = '2';
                    *ptr++ = ';';
                    break;
                case '&':
                    *ptr++ = '&';
                    *ptr++ = '#';
                    *ptr++ = '3';
                    *ptr++ = '8';
                    *ptr++ = ';';
                    break;
                case '\'':
                    *ptr++ = '&';
                    *ptr++ = '#';
                    *ptr++ = '3';
                    *ptr++ = '9';
                    *ptr++ = ';';
                    break;
                case '"':
                    *ptr++ = '&';
                    *ptr++ = '#';
                    *ptr++ = '3';
                    *ptr++ = '4';
                    *ptr++ = ';';
                    break;
                default:
                    *ptr++ = c;
                    break;
            }
        }
    } else {
        // Handle other codings.  We'll use a slower but easier approach since the vast
        // majority of strings we see are ASCII or MacRoman
        UniChar *buffer, *src;
        
        buffer = NSZoneMalloc(NULL, sizeof(*buffer) * characterCount);
        src = buffer;
        ptr = dest;
        CFStringGetCharacters(string, CFRangeMake(0, characterCount), buffer);
        for (characterIndex = 0; characterIndex < characterCount; characterIndex++, src++) {
            UniChar c;
            
            switch ((c = *src)) {
                case '<':
                    *ptr++ = '&';
                    *ptr++ = '#';
                    *ptr++ = '6';
                    *ptr++ = '0';
                    *ptr++ = ';';
                    break;
                case '>':
                    *ptr++ = '&';
                    *ptr++ = '#';
                    *ptr++ = '6';
                    *ptr++ = '2';
                    *ptr++ = ';';
                    break;
                case '&':
                    *ptr++ = '&';
                    *ptr++ = '#';
                    *ptr++ = '3';
                    *ptr++ = '8';
                    *ptr++ = ';';
                    break;
                case '\'':
                    *ptr++ = '&';
                    *ptr++ = '#';
                    *ptr++ = '3';
                    *ptr++ = '9';
                    *ptr++ = ';';
                    break;
                case '"':
                    *ptr++ = '&';
                    *ptr++ = '#';
                    *ptr++ = '3';
                    *ptr++ = '4';
                    *ptr++ = ';';
                    break;
					// case ranges weren't working for me for some reason
                default:
                    //fprintf(stderr, "Encoding 0x%04x\n", c);
                    if (c < 0x7f) {
                        *ptr++ = c;
                    } else if (c < 0xff) {
                        *ptr++ = '&';
                        *ptr++ = '#';
                        *ptr++ = 'x';
                        *ptr++ = NTDataBufferHexCharacterForDigit((c & 0xf0) >> 4);
                        *ptr++ = NTDataBufferHexCharacterForDigit((c & 0x0f) >> 0);
                        *ptr++ = ';';
                    } else {
                        *ptr++ = '&';
                        *ptr++ = '#';
                        *ptr++ = 'x';
                        *ptr++ = NTDataBufferHexCharacterForDigit((c & 0xf000) >> 12);
                        *ptr++ = NTDataBufferHexCharacterForDigit((c & 0x0f00) >>  8);
                        *ptr++ = NTDataBufferHexCharacterForDigit((c & 0x00f0) >>  4);
                        *ptr++ = NTDataBufferHexCharacterForDigit((c & 0x000f) >>  0);
                        *ptr++ = ';';
                    }
                    break;
            }
        }
        
        NSZoneFree(NULL, buffer);
    }
    
    NTDataBufferDidAppend(dataBuffer, ptr - dest);
}

