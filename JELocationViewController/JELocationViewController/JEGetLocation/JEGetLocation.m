//
//  JEGetLocation.m
//  JELocationViewController
//
//  Created by 尹现伟 on 14-12-25.
//  Copyright (c) 2014年 DNE Technology Co.,Ltd. All rights reserved.
//

#import "JEGetLocation.h"
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
            _manager.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //add by zhangzhenqiang
            _manager.locationManager.activityType = CLActivityTypeFitness;
            _manager.locationManager.distanceFilter = 1000.0;
            _manager.locationManager.pausesLocationUpdatesAutomatically = YES;
            
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
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0)
    {
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        [self.locationManager startUpdatingLocation];
    }
    [self.locationManager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {  case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
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


@implementation NSString (str)

-(NSString *)removeString:(NSString *)aString{
    return [self stringByReplacingOccurrencesOfString:aString withString:@""];
}

@end

