//
//  JEGetLocation.h
//  JELocationViewController
//
//  Created by 尹现伟 on 14-12-25.
//  Copyright (c) 2014年 DNE Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JEAnnotation.h"

@interface JEGetLocation : NSObject<CLLocationManagerDelegate>

/*!
 *  获取实例对象
 *
 *  @return JEGetLocation
 */
+ (id)sharedGetlocation;

/*!
 *  获取经纬度
 *
 *  @param isOk 是否成功
 *  @param userLocation 当前位置信息
 *  @param nearbyLocations 附近位置信息，（暂不支持）
 */
- (void)getLocation:(void (^) (BOOL isOk, JEAnnotation *userLocation, NSArray *nearbyLocations))success;

@end
@interface CLLocation (YCLocation)

/*!
 *  火星坐标转换地图坐标
 *
 *  @return CLLocationCoordinate2D
 */
- (CLLocationCoordinate2D)locationMarsFromEarth;

@end

@interface NSString (str)

-(NSString *)removeString:(NSString *)aString;

@end