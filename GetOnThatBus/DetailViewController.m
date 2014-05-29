//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Vik Denic on 5/28/14.
//
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>

@interface DetailViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *routesLabel;
@property (weak, nonatomic) IBOutlet UILabel *transfersLabel;
@property (weak, nonatomic) IBOutlet MKMapView *detailMapView;

@end

@implementation DetailViewController

// Sets text labels with the associated bus stop's information
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [self.selectedBusStopDictionary objectForKey:@"cta_stop_name"];
    self.addressLabel.text = [self.selectedBusStopDictionary objectForKey:@"cta_stop_name"];
    [self.addressLabel sizeToFit];
    self.routesLabel.text = [NSString stringWithFormat: @"Routes: %@",[self.selectedBusStopDictionary objectForKey:@"routes"]];

    if([self.selectedBusStopDictionary objectForKey:@"inter_modal"])
        {
        self.transfersLabel.text = [NSString stringWithFormat:@"Transfers: %@",[self.selectedBusStopDictionary objectForKey:@"inter_modal"]];
        }
        else
        {
            self.transfersLabel.text = @"No transfers at this location.";
        }

    // Zooms map view to specific bus stop
    NSString *longitudeString = [self.selectedBusStopDictionary objectForKey:@"longitude"];
    NSString *latitudeString = [self.selectedBusStopDictionary objectForKey:@"latitude"];
    float longitudeFloat = longitudeString.floatValue;
    float latitudeFloat = latitudeString.floatValue;

    self.detailPointLocation = [[MKPointAnnotation alloc] init];
    self.detailPointLocation.coordinate = CLLocationCoordinate2DMake(latitudeFloat, longitudeFloat);
    [self.detailMapView addAnnotation:self.detailPointLocation];

    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitudeFloat, longitudeFloat);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    [self.detailMapView setRegion:region animated:YES];
}

@end
