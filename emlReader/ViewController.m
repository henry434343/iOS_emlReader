//
//  ViewController.m
//  emlReader
//
//  Created by Chauster Kung on 2013/11/12.
//  Copyright (c) 2013年 Chauster Kung. All rights reserved.
//

#import "ViewController.h"
#import "EmlParse.h"
#import "EmlDecoder.h"
@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.array = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height)  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [NSThread detachNewThreadSelector:@selector(loadingData) toTarget:self withObject:nil];
}

- (void)loadingData{
    
    NSString *path = [NSString stringWithFormat:@"%@/Documents/MailDemo/",NSHomeDirectory()];
    NSMutableArray *sourceFiles = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil]];
    for (NSString *str in sourceFiles) {
        if (![str hasPrefix:@"."]) {
            [self.array addObject:str];
        }
    }
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [self.array objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *name = [self.array objectAtIndex:indexPath.row];
    NSString *path = [NSString stringWithFormat:@"%@/Documents/MailDemo/%@",NSHomeDirectory(),name];
    
    
    EmlParse *parse = [[EmlParse alloc] init];
    EmlItem *item = [parse getItem:path];
    
//    NSLog(@"---------------------%@----------------------",name);
//    NSLog(@"------------------------header---------------------");
//    NSLog(@"item.from : %@",item.from);
//    NSLog(@"item.to : %@",item.to);
//    NSLog(@"item.cc : %@",item.cc);
//    NSLog(@"item.date : %@",item.date);
//    NSLog(@"item.subject : %@",item.subject);
//
//    NSLog(@"item.content_Type : %@",item.content_Type);
//    NSLog(@"item.content_Transfer_Encodin : %@",item.content_Transfer_Encodin);
//
    
    ContentViewController *contentViewController = [[ContentViewController alloc] init];
    contentViewController.content = [NSMutableArray arrayWithObjects:item.from,item.to,item.cc,item.date,item.subject, nil ];
    
//    NSLog(@"------------------------content---------------------");
    for (int i = 0 ; i < item.content.count ; i++) {
        [contentViewController.content addObject:[item.content objectAtIndex:i]];
        
        NSLog(@"view content = %@",[item.content objectAtIndex:i]);
    }
    
    NSLog(@"is attachment %d",[item haveAttachment]);
    for (int i = 0 ; i < item.attachment_FileName.count ; i++) {
        
        if ([[item.attachment_FileData objectAtIndex:0] isKindOfClass:[NSData class]])
            [self writeToFileWithData:[item.attachment_FileData objectAtIndex:i] fileName:[item.attachment_FileName objectAtIndex:i]];
        else
            [self writeToFileWithString:[item.attachment_FileData objectAtIndex:i] fileName:[item.attachment_FileName objectAtIndex:i]];
        
    }
    
    [self.navigationController pushViewController:contentViewController animated:YES];
}

-(void) writeToFileWithData:(NSData*)fileData fileName:(NSString*)fileName{
    //get the documents directory:
    NSString *path = [NSString stringWithFormat:@"%@/Documents/Data/",NSHomeDirectory()];
    
    //make a file name to write the data to using the documents directory:
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", path,fileName];
    
    //save content to the documents directory
    [fileData writeToFile:filePath atomically:YES];
}

-(void) writeToFileWithString:(NSString*)fileData fileName:(NSString*)fileName{
    
    //get the documents directory:
    NSString *path = [NSString stringWithFormat:@"%@/Documents/Data/",NSHomeDirectory()];

    //make a file name to write the data to using the documents directory:
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", path,fileName];
    
    //save content to the documents directory
    
    [fileData writeToFile:filePath
     
              atomically:NO 
     
                encoding:NSStringEncodingConversionAllowLossy 
     
                   error:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
