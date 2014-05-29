//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Vik Denic on 5/28/14.
//
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "DetailViewController.h"
#import "PaceAnnotation.h"
#import "MetraAnnotation.h"


@interface ViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property NSArray *busStopsArray;
@property NSDictionary *selectedDictionary;

// Custom references subclassing MKPointAnnotation
@property PaceAnnotation *paceAnnotation;
@property MetraAnnotation *metraAnnotation;
@property MKPointAnnotation *noTransferAnnotation;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedDictionary = [[NSDictionary alloc]init];

    // Accesses and deserializes API
    NSURL *url = [NSURL URLWithString:@"https://s3.amazonaws.com/mobile-makers-lib/bus.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,
                                                                                                NSData *data,
                                                                                                            NSError *connectionError) {

        NSDictionary *amazonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        self.busStopsArray = [amazonDictionary objectForKey:@"row"];

        // Enumerates through each bus-stop's data in API
        for (NSDictionary *busDictionary in self.busStopsArray) {

            // Retrieves necessary data from API for each bus stop
            NSString *latitude = [busDictionary objectForKey:@"latitude"];
            NSString *longitude = [busDictionary objectForKey:@"longitude"];
            double latConvertedToDouble = [latitude doubleValue];
            double longConvertedToDouble = [longitude doubleValue];

            // Adds the appropriate custom class (which subclass PointAnnotationView) depending on the bus-stops transfer option
            NSString *transferMode = [busDictionary objectForKey:@"inter_modal"];

            if ([transferMode isEqualToString:@"Pace"])
            {
                self.paceAnnotation = [[PaceAnnotation alloc]init];
                self.paceAnnotation.coordinate = CLLocationCoordinate2DMake(latConvertedToDouble, longConvertedToDouble);
                self.paceAnnotation.title = [busDictionary objectForKey:@"cta_stop_name"];
                self.paceAnnotation.subtitle = [busDictionary objectForKey:@"routes"];
                [self.mapView addAnnotation:self.paceAnnotation];

            }
            else if ([transferMode isEqualToString:@"Metra"])
            {
                self.metraAnnotation = [[MetraAnnotation alloc]init];
                self.metraAnnotation.coordinate = CLLocationCoordinate2DMake(latConvertedToDouble, longConvertedToDouble);
                self.metraAnnotation.title = [busDictionary objectForKey:@"cta_stop_name"];
                self.metraAnnotation.subtitle = [busDictionary objectForKey:@"routes"];
                [self.mapView addAnnotation:self.metraAnnotation];

            }
            else
            {
                self.noTransferAnnotation = [[MKPointAnnotation alloc]init];
                self.noTransferAnnotation.coordinate = CLLocationCoordinate2DMake(latConvertedToDouble, longConvertedToDouble);
                self.noTransferAnnotation.title = [busDictionary objectForKey:@"cta_stop_name"];
                self.noTransferAnnotation.subtitle = [busDictionary objectForKey:@"routes"];
                [self.mapView addAnnotation:self.noTransferAnnotation];
            }
        }

        // Zooms map to Chicago area
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(41.84, -87.70);
        MKCoordinateSpan span = MKCoordinateSpanMake(.3, .3);
        MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
        [self.mapView setRegion:region];
    }];
}


#pragma mark - Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{

    // Creates pin for each custom-Annotation class reference
    MKPinAnnotationView* pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    [pin rightCalloutAccessoryView];
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    // Sets assoicated pin image depending on type of custom annotation class (Pace, Metra, or neither)
    if ([annotation isKindOfClass:[PaceAnnotation class]]) {
        pin.image = [UIImage imageNamed:@"pace"];
    }

    else if ([annotation isKindOfClass:[MetraAnnotation class]]) {
        pin.image = [UIImage imageNamed:@"metra"];
    }

    return pin;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // Identifies selected pins and adds it to array
    NSArray *selectedAnnotations = [[NSArray alloc]initWithArray:[self.mapView selectedAnnotations]];
    MKPointAnnotation *selectedPin = [selectedAnnotations objectAtIndex:0];
    for(NSDictionary *eachDictionary in self.busStopsArray)
    {
        // Finds the selected bus stop in the array of dictionaries by matching the name
        if([eachDictionary[@"cta_stop_name"] isEqualToString:selectedPin.title])
        {
            self.selectedDictionary = eachDictionary;
        }
    }
    [self performSegueWithIdentifier:@"DetailSegue" sender:self];
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *detailVC = [segue destinationViewController];
    detailVC.selectedBusStopDictionary = self.selectedDictionary;
}

@end
