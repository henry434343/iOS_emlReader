//
//  EmlDecoder.h
//  emlReader
//
//  Created by Chauster Kung on 2013/11/13.
//  Copyright (c) 2013年 Chauster Kung. All rights reserved.
//

#import <Foundation/Foundation.h>

#define encBig5   CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)
#define encUTF8   CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)
#define encgb2312 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

typedef enum {
    UTF8,
    Big5,
    gb2312
} Encoder;

@interface EmlDecoder : NSObject

+ (NSString*) decodedQuotedPrintable:(NSString*)string withEncoder:(Encoder)type;
+ (NSString*) decodedBase64:(NSString*)string withEncoder:(Encoder)type;

+ (NSData *)decodeBase64WithString:(NSString *)strBase64 ;

@end
