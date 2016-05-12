//
//  AddBeerViewController.m
//  BrewBuddy
//
//  Created by Kevin Stewart on 2016-03-02.
//  Copyright © 2016 Kevin Stewart. All rights reserved.
//  991 346 110
//
//  This class is both a view for existing entries and a view to add a new entry.
//

#import "AddBeerViewController.h"
#import "BeerEntry.h"
#import "BeerEntryStore.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>


@interface AddBeerViewController ()
    <UINavigationControllerDelegate, CLLocationManagerDelegate,
    UITextFieldDelegate, MKMapViewDelegate,
    UIPickerViewDelegate, UIPickerViewDataSource>
// Name of beer
@property (weak, nonatomic) IBOutlet UITextField *nameField;
// Brewery
@property (weak, nonatomic) IBOutlet UITextField *breweryField;
// Picker that shows types
@property (weak, nonatomic) IBOutlet UIPickerView *typePicker;
// Slider that represents rating
@property (weak, nonatomic) IBOutlet UISlider *ratingSlider;
// Displays rating to user
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
// Label to show date
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
// Map view to show location
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// Array of beer types
@property (nonatomic, strong) NSArray *beerTypes;
// location manager to handle location data
@property (nonatomic, strong) CLLocationManager *locationManager;
// current location that the user is in
@property (nonatomic) CLLocation *currentLocation;
// pinpoint to show location
@property (nonatomic, strong) MKPointAnnotation *pinPoint;


@end

@implementation AddBeerViewController


#pragma mark View Life Cycle

// Initializes views
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // set self as a mapview delegate so we can handle its messages
    _mapView.delegate = self;
    
    // set beer types
    self.beerTypes = @[
                       @"Lager",
                       @"India Pale Ale",
                       @"Pilsner",
                       @"Ale",
                       @"Stout",
                       @"Pilsner",
                       @"Wheat",
                       @"Belgian Ale",
                       @"Other"];
    
    // Set up default rating value
    self.ratingLabel.text = [NSString stringWithFormat:@"%d", self.entry.rating];
    self.ratingSlider.value = (float)self.entry.rating;
    
    // Show entry date
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateIntervalFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateIntervalFormatterNoStyle;
    }
    
    // assign values to labels
    self.dateLabel.text = [dateFormatter stringFromDate:self.entry.logDate];
    self.breweryField.text = self.entry.beerBrewer;
    self.ratingLabel.text = [NSString stringWithFormat:@"%d", self.entry.rating];
    self.nameField.text = self.entry.beerName;
    
    
    
    // set up typepicker spinner
    self.typePicker.delegate = self;
    self.typePicker.dataSource = self;
    [self.typePicker selectRow:4 inComponent:0 animated:YES];
    
    NSString *entryBeerType = self.entry.beerType;
    
    
    // Spin picker to the type of beer
    if ([self.beerTypes indexOfObjectIdenticalTo:entryBeerType])
    {
        int selectedTypeIndex =
        (int)[self.beerTypes indexOfObjectIdenticalTo:entryBeerType];
        
        [self.typePicker selectRow:selectedTypeIndex inComponent:0 animated:YES];
        
    } else
    {
        [self.typePicker selectRow:0 inComponent:0 animated:YES];
    }
    
    
    
    
    // Check if location is default and has not been saved
    if (self.entry.location.coordinate.latitude != 0 &&
            self.entry.location.coordinate.longitude != 0)
    {
        NSLog(@"Pin placed at saved location.");
        CLLocationCoordinate2D startCoord = self.entry.location.coordinate;
        
        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 200, 200)];
        
        [_mapView setRegion:adjustedRegion animated:YES];
        
        
        // Add a pin to current location
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        pin.coordinate = startCoord;
        pin.title = @"Saved Location";
        pin.subtitle = @"This is where you enjoyed that beer.";
        
        [_mapView addAnnotation:pin];

    }
    else
    {
        // start location manager if no location is set to determine location
        [self startLocationManager];
    }
    
}


// Set up UIBarButton Items if the item is new and is modal.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (self.isNew)
    {
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = doneItem;
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                       target:self
                                       action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelItem;
    }
    
    
}

// Saves beer data to model when view is dismissed
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    // Save changes to entry
    
    BeerEntry *entry = self.entry;
    entry.beerName = self.nameField.text;
    entry.beerBrewer = self.breweryField.text;
    entry.rating = ((ceil)(self.ratingSlider.value));
    if (_isNew)
    {
        CLLocation *locationToSave = [[CLLocation alloc]
            initWithLatitude:_pinPoint.coordinate.latitude
            longitude:_pinPoint.coordinate.longitude];
        entry.location = locationToSave;
    }
    entry.beerType = self.beerTypes[[_typePicker selectedRowInComponent:0]];

    
}


#pragma mark Controls

// Change rating label value to match slider
- (IBAction)ratingChanged:(id)sender
{
    int roundedVal = (ceil(_ratingSlider.value));
    self.ratingLabel.text = [NSString stringWithFormat:@"%d", roundedVal];
}

// Dismiss keyboard when background is tapped
- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}


#pragma mark UIPicker Methods

// PickerView setup
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// tell picker view how many beer types there are
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return self.beerTypes.count;
}

// populate picker view with beer types
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.beerTypes[row];
}

#pragma mark Locations

// setup location manager to start tracking location
- (void)startLocationManager
{
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    // Ask user for permissions
    [_locationManager requestWhenInUseAuthorization];
}

// Track location and place pin where you are once a location has been found
// by the locationmanager
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"Location Updated");
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(
        [locations lastObject].coordinate.latitude, [locations lastObject].coordinate.longitude);
    // set region to show in map
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 200, 200)];
    
    [_mapView setRegion:adjustedRegion animated:YES];
    
    
    // Add a pin to current location
    CLLocationCoordinate2D pinLocation;
    pinLocation.latitude = [locations lastObject].coordinate.latitude;
    pinLocation.longitude = [locations lastObject].coordinate.longitude;
    
    self.pinPoint = [[MKPointAnnotation alloc] init];
    _pinPoint.coordinate = pinLocation;
    _pinPoint.title = @"Current Location";
    _pinPoint.subtitle = @"This is where you're enjoying that beer.";
    
    [_mapView addAnnotation:_pinPoint];
    
    // once we have a view we can stop tracking location
    [_locationManager stopUpdatingLocation];
}



#pragma mark Storyboard

// dismiss view and save
- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

// cancel and don't save
- (void)cancel:(id)sender
{
    [[BeerEntryStore sharedStore]removeEntry:self.entry];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

// override entry setter to provide a UINavigationBar title too
- (void)setEntry:(BeerEntry *)entry
{
    _entry = entry;
    
    self.navigationItem.title = entry.beerName;
}


@end
