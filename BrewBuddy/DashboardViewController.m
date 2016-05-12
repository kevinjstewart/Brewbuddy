//
//  DashboardViewController.m
//  BrewBuddy
//
//  Created by Kevin Stewart on 2016-03-02.
//  Copyright © 2016 Kevin Stewart. All rights reserved.
//  991 346 110
//
//  Initial screen that can display a random beer
//

#import "DashboardViewController.h"

@interface DashboardViewController () <NSURLSessionDelegate>

// beer name label
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
// brewery name label
@property (weak, nonatomic) IBOutlet UILabel *breweryLabel;
// country name label
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
// save current session
@property (nonatomic) NSURLSession *session;
// store JSON data
@property (nonatomic, copy) NSDictionary *beers;

@end

@implementation DashboardViewController

// init with session configuration
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Create Session with the default configuration
        NSURLSessionConfiguration *config =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:nil];
    }
    return self;
}

// show beer whenever the background is tapped
- (IBAction)backgroundTapped:(id)sender
{
    [self fetchBeerOfTheDay];
}


// initialize text to nil and then fetch
- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"ViewWillAppear");
    self.nameLabel.text = nil;
    self.countryLabel.text = nil;
    self.breweryLabel.text = nil;
    [self fetchBeerOfTheDay];
    
}

// Change beer labels and make each field optional
- (void)changeBeerLabels:(NSDictionary *)details
{
    if (details[@"title"])
    {
        self.nameLabel.text = [NSString stringWithFormat:@"%@", details[@"title"]];
    } else
    {
        self.nameLabel.text = nil;
    }
    
    if (details[@"brewery"][@"title"])
    {
        self.breweryLabel.text = [NSString stringWithFormat:@"brewed by %@", details[@"brewery"][@"title"]];
    } else
    {
        self.breweryLabel.text = nil;
    }
    
    if (details[@"country"][@"title"])
    {
        self.countryLabel.text = [NSString stringWithFormat:@"in %@", details[@"country"][@"title"]];
    } else
    {
        self.countryLabel.text = nil;
    }
    
}

// Grab the JSON data and assign it to the beers array
- (void)fetchBeerOfTheDay
{
    // Create request
    NSString *requestString = @"https://prost.herokuapp.com/api/v1/beer/rand";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // make a data task with completion handler that assigns the result to the beers property
    NSURLSessionTask *dataTask =
    [self.session dataTaskWithRequest:req
                    completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error)
     {
         if (data == nil)
         {
             return;
         }
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                      error:nil];
         self.beers = jsonObject;
        
     }];
    // DataTasks are created in a paused state and must be resumed to start
    [dataTask resume];
    [self changeBeerLabels:_beers];
}

@end
