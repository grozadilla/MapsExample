//
//  GRUViewController.m
//  MapasPorElMundo
//
//  Created by user22769 on 25/05/14.
//  Copyright (c) 2014 gru. All rights reserved.
//

#import "GRUViewController.h"

@interface GRUViewController (){
    CLLocationManager  * locationManager;
    CLLocation * location;
}
@end

@implementation GRUViewController

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
    // Do any additional setup after loading the view from its nib.
    self.mapView.delegate = self;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPosition:)];
    
    tap.numberOfTapsRequired = 1;
    
    [self.mapView addGestureRecognizer:tap];
    
    [self warmUpGPS];
}

-(void)tapPosition:(UITapGestureRecognizer *) gesture{
    CGPoint point = [gesture locationInView:self.mapView];
    
    CLLocationCoordinate2D coordinates = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    location = [[CLLocation alloc] initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
    
    MKCoordinateRegion regionCurrentUser;
    regionCurrentUser.center.latitude = location.coordinate.latitude;
    regionCurrentUser.center.longitude = location.coordinate.longitude;
    
    [self.mapView setRegion:regionCurrentUser animated:YES];
    
    //geolocalizacion de las coordenadas al cp, calle, zona ... (no siempre se obtiene todo de todos los pntos)
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
        if (!error) {
            CLPlacemark * placeMark = [placemarks objectAtIndex:0];
            NSLog(@"%@",placeMark.addressDictionary);
        }
    }];
    
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - corelocation
-(void)warmUpGPS{
    locationManager = [[CLLocationManager alloc]init];
    //configurar la precision de la captura de la posicion
    locationManager.desiredAccuracy =kCLLocationAccuracyBest;
    
    locationManager.delegate = self;
    
    //iniciar la captura de la señal
    [locationManager startUpdatingLocation];
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    //aqui sabemos si tenemos permiso para usar GPS
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //l primer elemento del array sera la posicion mas actva.
    
//    NSLog(@"LAT %f - LONG %f", [[[[locations firstObject]objectForKey:@"coordinate"]valueForKey:@"latitude"]doubleValue],[[[[locations firstObject]objectForKey:@"coordinate"]valueForKey:@"longitude"]doubleValue]);
    
    location = [locations firstObject];
    NSLog(@"LAT %f - LONG %f", location.coordinate.latitude, location.coordinate.longitude);
    
    
    
    //es un buen stio para detener la localizacion
    [locationManager stopUpdatingLocation];
    
    //actualizar el mapa
    
    MKCoordinateRegion regionCurrentUser;
    regionCurrentUser.center.latitude = location.coordinate.latitude;
    regionCurrentUser.center.longitude = location.coordinate.longitude;
    
    [self.mapView setRegion:regionCurrentUser animated:YES];
}


#pragma mark - mapkit

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //para cambiar la imagen del punto etc...
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
}

//para manejar la tachuela
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    //es un buen stio para detener la localizacion
    //[locationManager stopUpdatingLocation];
    
    //actualizar el mapa
    
    MKCoordinateRegion regionCurrentUser;
    regionCurrentUser.center.latitude = userLocation.coordinate.latitude;
    regionCurrentUser.center.longitude = userLocation.coordinate.longitude;
    
    [self.mapView setRegion:regionCurrentUser animated:YES];
}


#pragma mark - limpiar al salir.

-(void)dealloc{
    self.mapView = nil;
}














@end
