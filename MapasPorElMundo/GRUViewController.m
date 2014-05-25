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
    
    id<MKOverlay> rutaOverlay;
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
    
    //detectamos el numero de toques
    //1. geocoding
    //2. rutas
    
    CGPoint point = [gesture locationInView:self.mapView];
    
    CLLocationCoordinate2D coordinates = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    switch (gesture.numberOfTouches) {
        case 0:{
            CLGeocoder *geocoder = [[CLGeocoder alloc]init];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
                if (!error) {
                    CLPlacemark * placeMark = [placemarks objectAtIndex:0];
                    NSLog(@"%@",placeMark.addressDictionary);
                }
            }];
        }
        break;
        case 1:{
            //calculamos rutas
            
            //tenemos que configurar el request para calcular la ruta, necsitamoslas coordenaadas de inicia  fin + tipo de transporte
            MKDirectionsRequest * request = [[MKDirectionsRequest alloc]init];
            request.transportType = MKDirectionsTransportTypeWalking;
            
            request.destination = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate: coordinates addressDictionary:nil]];
            
            request.source = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:location.coordinate addressDictionary:nil]];
            
            MKDirections * directions = [[MKDirections alloc]initWithRequest:request];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (!error) {
                    MKRoute *route = response.routes[0];
                    [self drawRoute:route];
                }
            }];
            
            
        }
        break;
        default:
            break;
    
    
    }
    
    /*location = [[CLLocation alloc] initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
    
    MKCoordinateRegion regionCurrentUser;
    regionCurrentUser.center.latitude = location.coordinate.latitude;
    regionCurrentUser.center.longitude = location.coordinate.longitude;
    
    [self.mapView setRegion:regionCurrentUser animated:YES];*/
    
    
}

-(void)drawRoute:(MKRoute *) route{
    if (rutaOverlay) {//si ya hay una ruta la elimino
        [self.mapView removeOverlay:rutaOverlay];
    }
    [self.mapView addOverlay:route.polyline];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    rutaOverlay = overlay;
    MKPolylineRenderer *renderLine = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    
    renderLine.strokeColor = [UIColor blueColor];
    renderLine.lineWidth = 3.0;
    
    return renderLine;
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
    [locationManager stopUpdatingLocation];
    
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
