//
//  JEViewController2.m
//  JELocationViewController
//
//  Created by 尹现伟 on 14-12-25.
//  Copyright (c) 2014年 DNE Technology Co.,Ltd. All rights reserved.
//

#import "JEViewController2.h"
#import "DPAPI.h"
#import "JEGetLocation.h"
#import <MapKit/MapKit.h>

@interface JEViewController2 ()<DPRequestDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) DPAPI *dpapi;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) NSInteger index;
@end

@implementation JEViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.dpapi = [[DPAPI alloc]init];
    
    [[JEGetLocation sharedGetlocation]getLocation:^(BOOL isOk, JEAnnotation *userLocation, NSArray *nearbyLocations) {
        if (isOk) {
            self.index = 1;
            [self getSurroundingInfo:userLocation.coordinate page:(int)self.index];
        }else{

        }
    }];
}


- (void)getSurroundingInfo:(CLLocationCoordinate2D)coordinate page:(int)page{

    [self.dpapi requestWithURL:@"v1/business/find_businesses" paramsString:[NSString stringWithFormat:@"latitude=%.6f&longitude=%.6f&radius=1000&sort=7&page=%d&limit=20",coordinate.latitude,coordinate.longitude,page] delegate:self];
}

#pragma mark - DPRequestDelegate

- (void)request:(DPRequest *)request didReceiveRawData:(NSData *)data;
{
    if (!self.dataArray) {
        self.dataArray = [NSMutableArray array];
    }

    NSDictionary *dict = [self json:data];
    NSArray *ary = [dict objectForKey:@"businesses"];
    for (NSDictionary *dict2 in ary) {
        JEAnnotation *ann = [[JEAnnotation alloc]init];
        ann.title = [[dict2 objectForKey:@"name"] removeString:@"(这是一条测试商户数据，仅用于测试开发，开发完成后请申请正式数据...)"];
        ann.subtitle = [dict2 objectForKey:@"address"];
        ann.coordinate = CLLocationCoordinate2DMake([[dict2 objectForKey:@"latitude"] doubleValue], [[dict2 objectForKey:@"longitude"] doubleValue]);

        [self.dataArray addObject:ann];
    }
    [self.tableView reloadData];
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"没有获取到附近信息" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
    [alert show];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellid = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
    }
    JEAnnotation *ann = self.dataArray[indexPath.row];
    cell.textLabel.text = ann.title;
    cell.detailTextLabel.text = ann.subtitle;
    return cell;
}





- (NSDictionary *)json:(NSData *)data{
    if (!data) {
        return nil;
    }
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
