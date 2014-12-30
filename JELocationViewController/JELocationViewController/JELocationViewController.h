//
//  JELocationViewController.h
//  GetSurroundingLocationInfo
//
//  Created by 尹现伟 on 14-8-25.
//  Copyright (c) 2014年 DNE Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DPAPI.h"
#import "VPPMapHelper.h"
#import "VPPMapCustomAnnotation.h"
#import "JEGetLocation.h"

@class JEAnnotations;

#define JELocationViewControllerNotification @"JELocationViewControllerNotification"
/*!
 *  调用大众点评API搜索附近位置信息并展示，点击cell发送通知，对象为JEAnnotation，包含经纬度、地址缩写和地址全写
 */
@interface JELocationViewController : UIViewController<MKMapViewDelegate>

/*!
 *  初始化方法
 *
 *  @param annotation coordinate title必须
 *
 */
//- (id)initWithAnnotation:(JEAnnotations *)annotation ;
//
//- (void)back;

@property (strong, nonatomic) JEAnnotations *annotation;
@property (strong, nonatomic) MKMapView *mapView;

@end





///*!
// *  标注数据模型
// */
//@interface JEAnnotations : NSObject <VPPMapCustomAnnotation>
//
//@property (nonatomic, assign) MKPinAnnotationColor pinAnnotationColor;
//
//@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
//
//@property (nonatomic, copy) NSString *title;
//
//@property (nonatomic, copy) NSString *subtitle;
//
//@property (nonatomic, assign) BOOL animatesDrop;
//
//@end
//
//
//@interface MKMapView (ZoomLevel)
//
///*!
// *  设置缩放级别
// *
// *  @param centerCoordinate 缩放的地图中心点
// *  @param zoomLevel        级别 < 28
// *  @param animated         是否动画显示
// */
//- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
//                  zoomLevel:(NSUInteger)zoomLevel
//                   animated:(BOOL)animated;
//
//@end

