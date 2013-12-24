//
//  EmlDecoder.m
//  emlReader
//
//  Created by Chauster Kung on 2013/11/13.
//  Copyright (c) 2013年 Chauster Kung. All rights reserved.
//

#import "EmlDecoder.h"




@implementation EmlDecoder

#pragma mark QuotedPrintable

+ (NSString*)decodedQuotedPrintable:(NSString *)string withEncoder:(Encoder)type{
    
    char *temp = [self replace1:(char *)[string UTF8String]];
    temp = [self replace2:temp];
    
    
    NSStringEncoding encoder;
    switch (type) {
        case UTF8: encoder = encUTF8; break;
        case Big5: encoder = encBig5; break;
        case gb2312: encoder = encgb2312; break;
        default: encoder = encUTF8; break;
    }
    
    return [NSString stringWithCString:temp
                              encoding:encoder];
}

+ (char *)replace1:(char const * const)original
{
    char const * const pattern = "=\r\n";
    
    size_t const patlen = strlen(pattern);
    size_t const orilen = strlen(original);
    
    size_t patcnt = 0;
    const char * oriptr;
    const char * patloc;
    
    // find how many times the pattern occurs in the original string
    for(oriptr = original;
        (patloc = strstr(oriptr, pattern));
        oriptr = patloc + patlen)
    {
        patcnt++;
    }
    
    {
        // allocate memory for the new string
        size_t const retlen = orilen - patcnt * patlen;
        char * const returned = (char *) malloc( sizeof(char) * (retlen + 1) );
        
        if(returned != NULL)
        {
            // copy the original string,
            // replacing all the instances of the pattern
            char * retptr = returned;
            for(oriptr = original;
                (patloc = strstr(oriptr, pattern));
                oriptr = patloc + patlen)
            {
                size_t const skplen = patloc - oriptr;
                // copy the section until the occurence of the pattern
                strncpy(retptr, oriptr, skplen);
                retptr += skplen;
            }
            // copy the rest of the string.
            strcpy(retptr, oriptr);
        }
        return returned;
    }
}

+ (char *)replace2:(char const * const)original
{
    size_t const replen = 1;
    size_t const patlen = 3;
    size_t const orilen = strlen(original);
    
    size_t patcnt = 0;
    const char * oriptr;
    const char * patloc;
    
    // find how many times the pattern occurs in the original string
    for(oriptr = original; (patloc = strstr(oriptr, "=")); oriptr = patloc + patlen)
    {
        patcnt++;
    }
    
    {
        // allocate memory for the new string
        size_t const retlen = orilen + patcnt * (replen - patlen);
        char * const returned = (char *) malloc( sizeof(char) * (retlen + 1) );
        
        if(returned != NULL)
        {
            // copy the original string,
            // replacing all the instances of the pattern
            char * retptr = returned;
            for(oriptr = original;
                (patloc = strstr(oriptr, "="));
                oriptr = patloc + patlen)
            {
                char newRep[3];
                
                newRep[0] = patloc[1];
                newRep[1] = patloc[2];
                newRep[2] = '\0';
                
                char _rep[2];
                _rep[0] = (char)(int)strtol(newRep, NULL, 16);
                _rep[1] = '\0';
                
                size_t const skplen = patloc - oriptr;
                // copy the section until the occurence of the pattern
                strncpy(retptr, oriptr, skplen);
                retptr += skplen;
                // copy the replacement
                strncpy(retptr, _rep, replen);
                retptr += replen;
            }
            // copy the rest of the string.
            strcpy(retptr, oriptr);
        }
        return returned;
    }
}

#pragma mark Base64

+ (NSString*)decodedBase64:(NSString *)string withEncoder:(Encoder)type{

    NSStringEncoding encoder;
    switch (type) {
        case UTF8: encoder = encUTF8; break;
        case Big5: encoder = encBig5; break;
        case gb2312: encoder = encgb2312; break;
        default: encoder = encUTF8; break;
    }
    
    return [[NSString alloc] initWithData:[self decodeBase64WithString:string] encoding:encoder];
}

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

+ (NSData *)decodeBase64WithString:(NSString *)strBase64 {
    const char *objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
    size_t intLength = strlen(objPointer);
    int intCurrent;
    int i = 0, j = 0, k;
    
    unsigned char *objResult = calloc(intLength, sizeof(unsigned char));
    
    // Run through the whole string, converting as we go
    while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
        if (intCurrent == '=') {
            if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
                // the padding character is invalid at this point -- so this entire string is invalid
                free(objResult);
                return nil;
            }
            continue;
        }
        
        intCurrent = _base64DecodingTable[intCurrent];
        if (intCurrent == -1) {
            // we're at a whitespace -- simply skip over
            continue;
        } else if (intCurrent == -2) {
            // we're at an invalid character
            free(objResult);
            return nil;
        }
        
        switch (i % 4) {
            case 0:
                objResult[j] = intCurrent << 2;
                break;
                
            case 1:
                objResult[j++] |= intCurrent >> 4;
                objResult[j] = (intCurrent & 0x0f) << 4;
                break;
                
            case 2:
                objResult[j++] |= intCurrent >>2;
                objResult[j] = (intCurrent & 0x03) << 6;
                break;
                
            case 3:
                objResult[j++] |= intCurrent;
                break;
        }
        i++;
    }
    
    // mop things up if we ended on a boundary
    k = j;
    if (intCurrent == '=') {
        switch (i % 4) {
            case 1:
                // Invalid state
                free(objResult);
                return nil;
                
            case 2:
                k++;
                // flow through
            case 3:
                objResult[k] = 0;
        }
    }
    
    // Cleanup and setup the return NSData
    NSData * objData = [[NSData alloc] initWithBytes:objResult length:j] ;
    free(objResult);
    return objData;
}



@end
