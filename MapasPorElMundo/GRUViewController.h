//
//  GRUViewController.h
//  MapasPorElMundo
//
//  Created by user22769 on 25/05/14.
//  Copyright (c) 2014 gru. All rights reserved.
//
@import MapKit;
#import <UIKit/UIKit.h>


@interface GRUViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak,nonatomic)IBOutlet MKMapView * mapView;

@end
