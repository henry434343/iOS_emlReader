//
//  ContentViewController.h
//  emlReader
//
//  Created by Chauster Kung on 2013/11/13.
//  Copyright (c) 2013年 Chauster Kung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray *content;
@end
