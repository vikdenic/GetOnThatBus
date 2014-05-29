//
//  DetailViewController.m
//  GetOnThatBus
//
//  Created by Vik Denic on 5/28/14.
//
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *routesLabel;
@property (weak, nonatomic) IBOutlet UILabel *transfersLabel;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [self.selectedBusStopDictionary objectForKey:@"cta_stop_name"];
    self.addressLabel.text = [self.selectedBusStopDictionary objectForKey:@"cta_stop_name"];
    [self.addressLabel sizeToFit];
    self.routesLabel.text = [self.selectedBusStopDictionary objectForKey:@"routes"];

    if([self.selectedBusStopDictionary objectForKey:@"inter_modal"])
        {
        self.transfersLabel.text = [self.selectedBusStopDictionary objectForKey:@"inter_modal"];
        }
        else
        {
            self.transfersLabel.text = @"No transfers at this location.";
        }

}

@end
