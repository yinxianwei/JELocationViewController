//
//  JELocationViewController.m
//  GetSurroundingLocationInfo
//
//  Created by 尹现伟 on 14-8-25.
//  Copyright (c) 2014年 DNE Technology Co.,Ltd. All rights reserved.
//

#import "JELocationViewController.h"

#define JE_SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define JE_SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width


@interface JELocationViewController ()<DPRequestDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DPAPI *dpapi;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation JELocationViewController

//- (id)initWithAnnotation:(JEAnnotations *)annotation{
//    self = [super init];
//    if (self) {
//        self.annotation = annotation;
//        self.coordinate = annotation.coordinate;
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    if (!_mapView) {
//        _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, [self height], JE_SCREEN_WIDTH, 150)];
//    }
////    self.mapView.showsUserLocation = YES;
////    _mapView.delegate = self;
//    [self.view addSubview:_mapView];
////    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
//    
//    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _mapView.frame.size.height+_mapView.frame.origin.y, JE_SCREEN_WIDTH, JE_SCREEN_HEIGHT - (_mapView.frame.size.height+_mapView.frame.origin.y)) style:UITableViewStylePlain];
//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
//    [self.view addSubview:self.tableView];
//    
//    _dpapi = [[DPAPI alloc] init];
//
//    self.dataArray = [NSMutableArray array];
//    
//    [self getSurroundingInfo:self.coordinate page:1];
//    
//    self.tableView.autoresizingMask = _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//}
//
//- (void)back{
//    if (self.navigationController) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//}
//
//#pragma mark - UITableViewDelegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [[NSNotificationCenter defaultCenter]postNotificationName:JELocationViewControllerNotification object:self.dataArray[indexPath.row] userInfo:nil];
//    [self back];
//}
//
//
//#pragma mark - UITableViewDataSource
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.dataArray.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellid = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
//    if (!cell) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
//    }
//    JEAnnotations *ann = self.dataArray[indexPath.row];
//    cell.textLabel.text = ann.title;
//    cell.detailTextLabel.text = ann.subtitle;
//    return cell;
//}
//
//
//
//- (void)getSurroundingInfo:(CLLocationCoordinate2D)coordinate page:(int)page{
//
//    [self.dpapi requestWithURL:@"v1/business/find_businesses" paramsString:[NSString stringWithFormat:@"latitude=%.6f&longitude=%.6f&radius=1000&sort=7&page=%d&limit=20",coordinate.latitude,coordinate.longitude,page] delegate:self];
//}
//
//#pragma mark - DPRequestDelegate
//
//- (void)request:(DPRequest *)request didReceiveRawData:(NSData *)data;
//{
//    [self.mapView removeOverlays:self.dataArray];
//    self.dataArray = [NSMutableArray array];
//
//    NSDictionary *dict = [self json:data];
//    NSArray *ary = [dict objectForKey:@"businesses"];
//    for (NSDictionary *dict2 in ary) {
//        JEAnnotations *ann = [[JEAnnotations alloc]init];
//        ann.title = [[dict2 objectForKey:@"name"] removeString:@"(这是一条测试商户数据，仅用于测试开发，开发完成后请申请正式数据...)"];
//        ann.subtitle = [dict2 objectForKey:@"address"];
//        ann.coordinate = CLLocationCoordinate2DMake([[dict2 objectForKey:@"latitude"] doubleValue], [[dict2 objectForKey:@"longitude"] doubleValue]);
//        ann.animatesDrop = NO;
//        [self.dataArray addObject:ann];
//    }
//    [self.tableView reloadData];
//    
//    VPPMapHelper *mapHelper = [VPPMapHelper VPPMapHelperForMapView:self.mapView
//                                                pinAnnotationColor:MKPinAnnotationColorRed
//                                             centersOnUserLocation:NO
//                                             showsDisclosureButton:NO
//                                                          delegate:nil];
//	mapHelper.userCanDropPin = YES;
//	mapHelper.allowMultipleUserPins = YES;
//	mapHelper.pinDroppedByUserClass = [JEAnnotations class];
//	[mapHelper setMapAnnotations:self.dataArray];
//}
//
//- (void)request:(DPRequest *)request didFailWithError:(NSError *)error {
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"没有获取到附近信息" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
//    [alert show];
//}
//
//#pragma mark - MKMapViewDelegate
//
//- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
//{
//    MKPinAnnotationView *pinView = nil;
//    if(annotation != self.mapView.userLocation)
//    {
//        static NSString *defaultPinID = @"annid";
//        pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
//                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID];
//        pinView.pinColor = MKPinAnnotationColorGreen;
//        pinView.canShowCallout = YES;
//    }
//    else {
//        [self.mapView.userLocation setTitle:self.annotation.title];
//    }
//    return pinView;
//}
//
//- (NSDictionary *)json:(NSData *)data{
//    if (!data) {
//        return nil;
//    }
//    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    return dict;
//}
//
//- (CGFloat)height{
//    CGFloat h = self.navigationController ? 44.f : 0.f;
//    CGFloat h2 = (([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0 ? YES : NO) ? 20.f : 0.f);
//    return (h + h2);
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//@end
//
//
//
//
//
//@implementation JEAnnotations
//
//@synthesize coordinate;
//@synthesize title;
//@synthesize subtitle;
//@synthesize pinAnnotationColor;
//@synthesize opensWhenShown;
//@synthesize image;
//@end
//
//
//
//
//#define MERCATOR_OFFSET 268435456
//#define MERCATOR_RADIUS 85445659.44705395
//
//@implementation MKMapView (ZoomLevel)
//
//#pragma mark -
//#pragma mark Map conversion methods
//
//- (double)longitudeToPixelSpaceX:(double)longitude
//{
//    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
//}
//
//- (double)latitudeToPixelSpaceY:(double)latitude
//{
//    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
//}
//
//- (double)pixelSpaceXToLongitude:(double)pixelX
//{
//    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
//}
//
//- (double)pixelSpaceYToLatitude:(double)pixelY
//{
//    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
//}
//
//#pragma mark -
//#pragma mark Helper methods
//
//- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
//                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
//                                 andZoomLevel:(NSUInteger)zoomLevel
//{
//    // convert center coordiate to pixel space
//    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
//    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
//    
//    // determine the scale value from the zoom level
//    NSInteger zoomExponent = 20 - zoomLevel;
//    double zoomScale = pow(2, zoomExponent);
//    
//    // scale the map’s size in pixel space
//    CGSize mapSizeInPixels = mapView.bounds.size;
//    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
//    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
//    
//    // figure out the position of the top-left pixel
//    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
//    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
//    
//    // find delta between left and right longitudes
//    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
//    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
//    CLLocationDegrees longitudeDelta = maxLng - minLng;
//    
//    // find delta between top and bottom latitudes
//    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
//    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
//    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
//    
//    // create and return the lat/lng span
//    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
//    return span;
//}
//
//#pragma mark -
//#pragma mark Public methods
//
//- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
//                  zoomLevel:(NSUInteger)zoomLevel
//                   animated:(BOOL)animated
//{
//    // clamp large numbers to 28
//    zoomLevel = MIN(zoomLevel, 28);
//    
//    // use the zoom level to compute the region
//    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
//    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
//    
//    // set the region like normal
//    [self setRegion:region animated:animated];
//}
@end

