//
//  JEAnnotation.h
//  JELocationViewController
//
//  Created by 尹现伟 on 14-12-25.
//  Copyright (c) 2014年 DNE Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JEAnnotation : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *subtitle;

@end
