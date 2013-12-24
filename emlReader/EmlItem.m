//
//  EmlItem.m
//  emlReader
//
//  Created by Chauster Kung on 2013/11/12.
//  Copyright (c) 2013年 Chauster Kung. All rights reserved.
//

#import "EmlItem.h"

@implementation EmlItem

- (BOOL)haveAttachment {
    if (self.attachment_FileName.count > 0)
        return TRUE;
    else
        return FALSE;
}

- (NSInteger)attachmentCount {
    return self.attachment_FileName.count;
}
@end
