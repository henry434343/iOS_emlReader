//
//  EmlParse.h
//  emlReader
//
//  Created by Chauster Kung on 2013/11/12.
//  Copyright (c) 2013年 Chauster Kung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmlItem.h"

@interface EmlParse : NSObject

- (EmlItem*)getItem:(NSString*)filePath;

@end
