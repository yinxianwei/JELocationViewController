//
//  JEViewController.m
//  JELocationViewController
//
//  Created by 尹现伟 on 14-8-25.
//  Copyright (c) 2014年 DNE Technology Co.,Ltd. All rights reserved.
//

#import "JEViewController.h"
#import "JELocationViewController.h"

@interface JEViewController ()

@property (strong, nonatomic) UIButton *button;

@property (strong, nonatomic) JEAnnotations *annotation;


@end

@implementation JEViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.button = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 40)];
    [self.view addSubview:self.button];
    self.button.backgroundColor = [UIColor lightGrayColor];
    [self.button addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    
    

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test2:) name:JELocationViewControllerNotification object:nil];
//    
//    [[JEGetLocation sharedGetlocation]getLocation:^(BOOL isOk, JEAnnotation *userLocation, NSArray *nearbyLocations) {
//        if (isOk) {
//            self.annotation = userLocation;
//            [self.button setTitle:userLocation.title forState:UIControlStateNormal];
//        }
//        else{
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有获取到当前位置信息" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
//            [alert show];
//        }
//    }];
}




//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    switch (status) {
//        case kCLAuthorizationStatusNotDetermined:
//            if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//                [locationManager requestWhenInUseAuthorization];
//            }
//            break;
//        default:
//            break;
//    }
//}
//
//- (void)test{
//    [[JEGetLocation sharedGetlocation]getLocation:^(BOOL isOk, JEAnnotation *userLocation, NSArray *nearbyLocations) {
//        if (isOk) {
//            self.annotation = userLocation;
//            JELocationViewController *jevc = [[JELocationViewController alloc]initWithAnnotation:userLocation];
//            [self presentViewController:jevc animated:YES completion:nil];
//        }
//        else{
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有获取到当前位置信息" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
//            [alert show];
//        }
//    }];
//    
//}
//
//- (void)test2:(NSNotification *)notification{
//    if ([notification.name isEqualToString:JELocationViewControllerNotification]) {
//        self.annotation = (JEAnnotation *)notification.object;
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"title:%@\nsubtitle:%@\nlocation:%.6f,%.6f",self.annotation.title,self.annotation.subtitle,self.annotation.coordinate.latitude,self.annotation.coordinate.longitude] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
//        [alert show];
//        [self.button setTitle:self.annotation.title forState:UIControlStateNormal];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
