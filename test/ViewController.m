//
//  ViewController.m
//  test
//
//  Created by ming on 14-7-26.
//  Copyright (c) 2014年 ming. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){

    UITableView *table;
    NSArray *tableData;
    
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.view.backgroundColor = [UIColor whiteColor];
    
    tableData = @[@"人脸裁剪",@"人脸替换"];
    [self initTable];
    
}

-(void)btnTouch{
    
    //get Path

//    CGPathRef path = [self getPath:faceImage.size];
//    
//    //cut image
//    faceImage = [faceImage cutImageWithPath:path];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table
-(void)initTable{
    
    if (table == nil) {
        table=[[UITableView alloc]initWithFrame:CGRectMake(0, 20, KMainScreenWidth, KMainScreenHeight - 20) style:UITableViewStylePlain];
    }
    
    table.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    table.backgroundColor=[UIColor whiteColor];
    table.tableFooterView = [[UIView alloc] init];
    table.delegate=self;
    table.dataSource=self;
    table.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:table];
    
}
#pragma mark table delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
        {
            
            FaceFromPhoto *cutFace = [[FaceFromPhoto alloc]init];
            [self presentViewController:cutFace animated:NO completion:^{}];

        }
            break;
        case 1:
        {
            TakePhotoForReplace *camera = [[TakePhotoForReplace alloc]init];
            [self presentViewController:camera animated:NO completion:^{}];
        }
            break;
        case 2:
        {
            
        }
            break;
            
        default:
            break;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return tableData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier=[NSString stringWithFormat:@"reuseIdentifier"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
        //        cell.backgroundColor = [UIColor redColor];
    }
    cell.textLabel.text = tableData[indexPath.row];
    // Configure the cell...
    
    return cell;
}




@end
