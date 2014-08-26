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

- (id)initWithAnnotation:(JEAnnotation *)annotation{
    self = [super init];
    if (self) {
        self.annotation = annotation;
        self.coordinate = annotation.coordinate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_mapView) {
        _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, [self height], JE_SCREEN_WIDTH, 150)];
    }
    self.mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _mapView.frame.size.height+_mapView.frame.origin.y, JE_SCREEN_WIDTH, JE_SCREEN_HEIGHT - (_mapView.frame.size.height+_mapView.frame.origin.y)) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    _dpapi = [[DPAPI alloc] init];

    self.dataArray = [NSMutableArray array];
    
    [self getSurroundingInfo:self.coordinate page:1];
    
    self.tableView.autoresizingMask = _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
}

- (void)back{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:JELocationViewControllerNotification object:self.dataArray[indexPath.row] userInfo:nil];
    [self back];
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



- (void)getSurroundingInfo:(CLLocationCoordinate2D)coordinate page:(int)page{

    [self.dpapi requestWithURL:@"v1/business/find_businesses" paramsString:[NSString stringWithFormat:@"latitude=%.6f&longitude=%.6f&radius=1000&sort=7&page=%d&limit=20",coordinate.latitude,coordinate.longitude,page] delegate:self];
}

#pragma mark - DPRequestDelegate

- (void)request:(DPRequest *)request didReceiveRawData:(NSData *)data;
{
    [self.mapView removeOverlays:self.dataArray];
    self.dataArray = [NSMutableArray array];

    NSDictionary *dict = [self json:data];
    NSArray *ary = [dict objectForKey:@"businesses"];
    for (NSDictionary *dict2 in ary) {
        JEAnnotation *ann = [[JEAnnotation alloc]init];
        ann.title = [[dict2 objectForKey:@"name"] removeString:@"(这是一条测试商户数据，仅用于测试开发，开发完成后请申请正式数据...)"];
        ann.subtitle = [dict2 objectForKey:@"address"];
        ann.coordinate = CLLocationCoordinate2DMake([[dict2 objectForKey:@"latitude"] doubleValue], [[dict2 objectForKey:@"longitude"] doubleValue]);
        ann.animatesDrop = NO;
        [self.dataArray addObject:ann];
    }
    [self.tableView reloadData];
    
    VPPMapHelper *mapHelper = [VPPMapHelper VPPMapHelperForMapView:self.mapView
                                                pinAnnotationColor:MKPinAnnotationColorRed
                                             centersOnUserLocation:NO
                                             showsDisclosureButton:NO
                                                          delegate:nil];
	mapHelper.userCanDropPin = YES;
	mapHelper.allowMultipleUserPins = YES;
	mapHelper.pinDroppedByUserClass = [JEAnnotation class];
	[mapHelper setMapAnnotations:self.dataArray];
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"没有获取到附近信息" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation)
    {
        static NSString *defaultPinID = @"annid";
        pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = YES;
    }
    else {
        [self.mapView.userLocation setTitle:self.annotation.title];
    }
    return pinView;
}

- (NSDictionary *)json:(NSData *)data{
    if (!data) {
        return nil;
    }
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dict;
}

- (CGFloat)height{
    CGFloat h = self.navigationController ? 44.f : 0.f;
    CGFloat h2 = (([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0 ? YES : NO) ? 20.f : 0.f);
    return (h + h2);
}

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



@implementation CLLocation (YCLocation)

- (CLLocationCoordinate2D)locationMarsFromEarth
{
    double lat = 0.0;
    double lng = 0.0;
    transform_earth_from_mars(self.coordinate.latitude, self.coordinate.longitude, &lat, &lng);
    return [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng)
                                         altitude:self.altitude
                               horizontalAccuracy:self.horizontalAccuracy
                                 verticalAccuracy:self.verticalAccuracy
                                           course:self.course
                                            speed:self.speed
                                        timestamp:self.timestamp].coordinate;
}

void transform_earth_from_mars(double lat, double lng, double* tarLat, double* tarLng);

const double a = 6378245.0;
const double ee = 0.00669342162296594323;

bool transform_sino_out_china(double lat, double lon)
{
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

double transform_earth_from_mars_lat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

double transform_earth_from_mars_lng(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

void transform_earth_from_mars(double lat, double lng, double* tarLat, double* tarLng)
{
    if (transform_sino_out_china(lat, lng))
    {
        *tarLat = lat;
        *tarLng = lng;
        return;
    }
    double dLat = transform_earth_from_mars_lat(lng - 105.0, lat - 35.0);
    double dLon = transform_earth_from_mars_lng(lng - 105.0, lat - 35.0);
    double radLat = lat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    *tarLat = lat + dLat;
    *tarLng = lng + dLon;
}

@end



@interface JEGetLocation ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) void (^success)(BOOL isOk, JEAnnotation *userLocation, NSArray *nearbyLocations);

@end


@implementation JEGetLocation

static JEGetLocation *_manager = NULL;

+ (id)sharedGetlocation{
    @synchronized (self) {
        if (nil == _manager) {
            _manager = [[self alloc] init];
            _manager.locationManager = [[CLLocationManager alloc]init];
            _manager.locationManager.delegate=_manager;
            _manager.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
            _manager.locationManager.distanceFilter=1000.0f;
        }
    }
    return _manager;
}

+(id)alloc {
    @synchronized (self) {
        if (nil == _manager) {
            _manager = [super alloc];
        }
    }
    return _manager;
}


- (void)getLocation:(void (^) (BOOL isOk, JEAnnotation *userLocation, NSArray *nearbyLocations))success{
    self.success = success;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 5.0){
        
        [self.locationManager stopUpdatingLocation];

        printf("latitude %+.6f, longitude %+.6f\n",
               newLocation.coordinate.latitude,
               newLocation.coordinate.longitude);
        
        CLLocationCoordinate2D ll2d = [newLocation locationMarsFromEarth];
        
        CLLocation *location = [[CLLocation alloc]initWithLatitude:ll2d.latitude longitude:ll2d.longitude];
        
        CLGeocoder* geocoder = [[CLGeocoder alloc] init];
        
        [geocoder reverseGeocodeLocation:location completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if (error) {
                 if (self.success) {
                     self.success(NO,nil,nil);
                 }
             }
             else{
                 NSString *title = @"";
                 NSString *subtitle = @"";
                 for (CLPlacemark *placemark in placemarks) {
                     title = placemark.thoroughfare.length != 0 ? [NSString stringWithFormat:@"%@,%@,%@",placemark.administrativeArea,placemark.subLocality,placemark.thoroughfare] : [[placemark.name removeString:placemark.country] removeString:placemark.administrativeArea];
                     NSArray *ary = [placemark.addressDictionary objectForKeyedSubscript:@"FormattedAddressLines"];
                     if (ary.count>0) {
                         subtitle = ary[0];
                     }
                 }
                 JEAnnotation *ann = [[JEAnnotation alloc]init];
                 ann.coordinate = newLocation.coordinate;
                 ann.title = title;
                 ann.subtitle = subtitle;
                 self.success(YES, ann, nil);
             }
         }];
    }
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    self.success(NO, nil, nil);
}
@end



@implementation JEAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize pinAnnotationColor;
@synthesize opensWhenShown;
@synthesize image;
@end




#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@implementation MKMapView (ZoomLevel)

#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}
@end

@implementation NSString (str)

-(NSString *)removeString:(NSString *)aString{
    return [self stringByReplacingOccurrencesOfString:aString withString:@""];
}

@end