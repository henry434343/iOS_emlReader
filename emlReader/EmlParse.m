//
//  EmlParse.m
//  emlReader
//
//  Created by Chauster Kung on 2013/11/12.
//  Copyright (c) 2013年 Chauster Kung. All rights reserved.
//

#import "EmlParse.h"
#import "EmlDecoder.h"


@interface EmlParse() {
    
    NSString *emlHeader;
    NSString *emlContent;
    
    EmlItem *item;
}

@end

@implementation EmlParse

-(EmlItem *)getItem:(NSString *)filePath {
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    if (exists) {
        
        [self itemInit];
        [self divideEML:[[NSString alloc] initWithContentsOfFile:filePath encoding:encUTF8 error:nil]];
        
        return item;
    }
    else
        return nil;
}

- (void)itemInit {
    item = [[EmlItem alloc] init];
    item.from = @"";
    item.to = @"";
    item.cc = @"";
    item.date = @"";
    item.subject = @"";
}

- (void)divideEML:(NSString*)emlData {
    
    NSArray *array = [emlData componentsSeparatedByString:@"\r\n\r\n"];
    emlHeader = [array objectAtIndex:0];
    [self parseHeader:emlHeader];
    [self parseContent:array];
}

#pragma mark Header Text Parse

- (NSArray*)getHeaderfieldName {
    
    return [[NSArray alloc] initWithObjects:
            @"Return-Path",
            @"Received",
            @"From",
            @"Content-Type",
            @"Message-Id",
            @"Mime-Version",
            @"Subject",
            @"Date",
            @"References",
            @"To",
            @"In-Reply-To",
            @"X-Mailer",
            @"Content-Transfer-Encoding",
            @"acceptlanguage",
            @"X-MS-TNEF-Correlator",
            @"X-MS-Exchange-Organization-SCL",
            @"X-Auto-Response-Suppress",
            @"Accept-Language",
            @"Content-Language",
            @"X-MS-Exchange-Organization-AuthAs",
            @"X-MS-Exchange-Organization-AuthMechanism",
            @"Thread-Topic",
            @"Thread-Index",
            @"X-Priority",
            @"Importance",
            @"Disposition-Notification-To",
            @"MIME-Version",
            @"CC",
            @"X-Universally-Unique-Identifier",nil];
}

- (void)parseHeader:(NSString*)header {
    
    NSLog(@"----------------------Header Source ------------------------");
    NSArray *array = [header componentsSeparatedByString:@"\n"];
    NSArray *headerField = [self getHeaderfieldName];
    for (int i = 0; i < array.count; i++) {
        NSString *str = [array objectAtIndex:i];

        if ([str hasPrefix:@"From:"]) {
            
            item.from = [str substringFromIndex:NSMaxRange([str rangeOfString:@"From: "])];
            int count = 1;
            @try {
                while (![headerField containsObject:[[array objectAtIndex:i+count] componentsSeparatedByString:@":"][0]]) {
                    item.from = [NSString stringWithFormat:@"%@%@",item.from,[array objectAtIndex:i+count]];
                    count ++;
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                item.from = [self parseHeaderText:item.from];
            }
        }
        
        else if ([str hasPrefix:@"To:"]) {
            
            item.to = [str substringFromIndex:NSMaxRange([str rangeOfString:@"To: "])];
            int count = 1;
            @try {
                while (![headerField containsObject:[[array objectAtIndex:i+count] componentsSeparatedByString:@":"][0]]) {
                    item.to = [NSString stringWithFormat:@"%@%@",item.to,[array objectAtIndex:i+count]];
                    count ++;
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                item.to = [self parseHeaderText:item.to];
            }
        }
        
        else if ([str hasPrefix:@"Subject:"]) {
            
            item.subject = [str substringFromIndex:NSMaxRange([str rangeOfString:@"Subject: "])];
            int count = 1;
            @try {
                while (![headerField containsObject:[[array objectAtIndex:i+count] componentsSeparatedByString:@":"][0]]) {
                    item.subject = [NSString stringWithFormat:@"%@%@",item.subject,[array objectAtIndex:i+count]];
                    count ++;
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                item.subject = [self parseHeaderText:item.subject];
            }
        }
        
        else if ([str hasPrefix:@"Date:"])
            item.date = [str substringFromIndex:NSMaxRange([str rangeOfString:@"Date: "])];
        
        else if ([str hasPrefix:@"CC:"]) {
            
            item.cc = [str substringFromIndex:NSMaxRange([str rangeOfString:@"CC: "])];
            int count = 1;
            @try {
                while (![headerField containsObject:[[array objectAtIndex:i+count] componentsSeparatedByString:@":"][0]]) {
                    item.cc = [NSString stringWithFormat:@"%@%@",item.cc,[array objectAtIndex:i+count]];
                    count ++;
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                item.cc = [self parseHeaderText:item.cc];
            }
        }
        
        else if ([str hasPrefix:@"Content-Type:"]) {
        
            item.content_Type = [str substringFromIndex:NSMaxRange([str rangeOfString:@"Content-Type: "])];
            int count = 1;
            @try {
                while (![headerField containsObject:[[array objectAtIndex:i+count] componentsSeparatedByString:@":"][0]]) {
                    item.content_Type = [NSString stringWithFormat:@"%@%@",item.content_Type,[array objectAtIndex:i+count]];
                    count ++;
                }
            }
            @catch (NSException *exception) {}
        }
        
        else if ([str hasPrefix:@"Content-Transfer-Encoding:"])
            item.content_Transfer_Encodin = [str substringFromIndex:NSMaxRange([str rangeOfString:@"Content-Transfer-Encoding: "])];
    
    }
}

- (NSString*)parseHeaderText:(NSString*)str{
    
    NSString *text = @"";
    NSArray *splitFirst  = [str componentsSeparatedByString:@"?="];
    for (NSString *needDecoder in splitFirst) {
        if ([needDecoder rangeOfString:@"=?"].location != NSNotFound) {
            NSArray *array = [needDecoder componentsSeparatedByString:@"=?"];
            NSString *string = [self textDecode:[array lastObject]];
            text = [NSString stringWithFormat:@"%@%@%@",text,[array objectAtIndex:0],string];
        }
        else
            text = [NSString stringWithFormat:@"%@%@",text,needDecoder];
    }

    return text;
}

- (NSString*)textDecode:(NSString*)text{
    
    NSArray *array = [text componentsSeparatedByString:@"?"];
    
    Encoder encoder ;
    NSString *enc = [[array objectAtIndex:0] lowercaseString];
    if ([enc isEqualToString:@"utf-8"]) encoder = UTF8;
    else if ([enc isEqualToString:@"big5"]) encoder = Big5;
    else encoder = gb2312;
    
    NSString *decode = [[array objectAtIndex:1] lowercaseString];
    if ([[decode lowercaseString] isEqualToString:@"q"])
        text = [EmlDecoder decodedQuotedPrintable:[array objectAtIndex:2] withEncoder:encoder];
    else if ([[decode lowercaseString] isEqualToString:@"b"])
        text = [EmlDecoder decodedBase64:[array objectAtIndex:2] withEncoder:encoder];
    
    return text;
}

#pragma mark Content Text Parse

- (void)parseContent:(NSArray*)array {
    
    item.content = [NSMutableArray array];
    item.attachment_FileName = [NSMutableArray array];
    item.attachment_FileData = [NSMutableArray array];
    
    
    NSMutableArray *contentArray = [[NSMutableArray alloc] initWithArray:array];
    [contentArray removeObjectAtIndex:0];
    
    // text/html   text/plain
    if ([item.content_Type.lowercaseString rangeOfString:@"text/html"].location != NSNotFound ||
        [item.content_Type.lowercaseString rangeOfString:@"text/plain"].location != NSNotFound) {
    
        [self parseWithContentType_Text:contentArray];
    }
    // multipart
    else if ([item.content_Type.lowercaseString rangeOfString:@"multipart"].location != NSNotFound){
        
        [self parseWithContentType_Multipart:contentArray];
    }
}

- (Encoder)detectEncoder:(NSString*)string {
    
    Encoder enc;
    if ([string.lowercaseString rangeOfString:@"big5"].location != NSNotFound) enc = Big5;
    else if ([string.lowercaseString rangeOfString:@"gb2312"].location != NSNotFound) enc = gb2312;
    else if ([string.lowercaseString rangeOfString:@"utf-8"].location != NSNotFound) enc = UTF8;
    else enc = UTF8;
    
    return enc;
}

- (void)parseWithContentType_Text:(NSMutableArray*)array {
    
    NSString *content = @"";
    for (NSString *str in array)
        content = [NSString stringWithFormat:@"%@\n%@",content,str];
    
    if ([item.content_Transfer_Encodin rangeOfString:@"quoted-printable"].location != NSNotFound)
        [item.content addObject:[EmlDecoder decodedQuotedPrintable:content withEncoder:[self detectEncoder:item.content_Type]]];
    else if ([item.content_Transfer_Encodin rangeOfString:@"base64"].location != NSNotFound)
        [item.content addObject:[EmlDecoder decodedBase64:content withEncoder:[self detectEncoder:item.content_Type]]];
    else
        [item.content addObject:content];
}

- (void)parseWithContentType_Multipart:(NSMutableArray*)array {
    NSString *boundary;
    if ([item.content_Type rangeOfString:@"boundary=\""].location != NSNotFound) {
        boundary = [item.content_Type substringFromIndex:NSMaxRange([item.content_Type rangeOfString:@"boundary=\""])];
        boundary = [boundary substringToIndex:NSMaxRange([boundary rangeOfString:@"\""])];
        boundary = [boundary substringToIndex:[boundary length]-1];
    }
    else
        boundary = [item.content_Type substringFromIndex:NSMaxRange([item.content_Type rangeOfString:@"boundary="])];
    
    boundary = [boundary stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    boundary = [boundary stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    
    [self multipartParse:array boundary:boundary];
}

- (void)multipartParse:(NSArray*)array boundary:(NSString*)boundary{
    
    for (int i = 0; i < array.count; i++) {
        if ([[array objectAtIndex:i] rangeOfString:boundary].location != NSNotFound) {
            int count = 1;
            NSString *content = @"";
            @try {
                
                while ([[array objectAtIndex:i+count] rangeOfString:boundary].location == NSNotFound || [[array objectAtIndex:i+count] rangeOfString:[NSString stringWithFormat:@"--%@",boundary]].location != NSNotFound) {
                    content = [NSString stringWithFormat:@"%@\n%@",content,[array objectAtIndex:i+count]];
                    count ++;
                    if ([content rangeOfString:[NSString stringWithFormat:@"--%@",boundary]].location != NSNotFound) {
                        content = [content substringToIndex:NSMaxRange([content rangeOfString:[NSString stringWithFormat:@"--%@",boundary]])];
                        content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"--%@",boundary] withString:@""];
                        break;
                    }
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
                //只有multipart/mixed才有附加檔案
                if ([item.content_Type rangeOfString:@"multipart/mixed"].location != NSNotFound) {
                    NSString *string = [array objectAtIndex:i];
                    if ([string rangeOfString:@"name="].location != NSNotFound) {
                        NSString *fileName;
                        
                        @try {
                            fileName = [string substringFromIndex:NSMaxRange([string rangeOfString:@"name=\""])];
                            fileName = [fileName substringToIndex:NSMaxRange([fileName rangeOfString:@"\""])];
                            fileName = [fileName substringToIndex:[fileName length]-1];
                        }
                        @catch (NSException *exception) {
                            fileName = [string substringFromIndex:NSMaxRange([string rangeOfString:@"name="])];
                            fileName = [fileName substringToIndex:NSMaxRange([fileName rangeOfString:@"\n"])];
                        }
                        [item.attachment_FileName addObject:fileName];
                        
                        if ([string.lowercaseString rangeOfString:@"base64"].location != NSNotFound)
                            [item.attachment_FileData addObject:[EmlDecoder decodeBase64WithString:content]];
                        else
                            [item.attachment_FileData addObject:content];
                        
                        continue;
                    }
                }
                
                
                if ([[[array objectAtIndex:i] lowercaseString] rangeOfString:@"quoted-printable"].location != NSNotFound) {
                    content = [EmlDecoder decodedQuotedPrintable:content withEncoder:[self detectEncoder:[array objectAtIndex:i]]];
                }
                else if ([[[array objectAtIndex:i] lowercaseString] rangeOfString:@"base64"].location != NSNotFound) {
                    content = [EmlDecoder decodedBase64:content withEncoder:[self detectEncoder:[array objectAtIndex:i]]];
                }
                
                if (![content isEqualToString:@""]) 
                    [item.content addObject:content];
            }
        }
    }
}

@end
