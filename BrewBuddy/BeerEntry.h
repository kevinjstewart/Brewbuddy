//
//  BeerEntry.h
//  BrewBuddy
//
//  Created by Kevin Stewart on 2016-03-02.
//  Copyright © 2016 Kevin Stewart. All rights reserved.
//  991 346 110
//
//  Beer Entry managed object header with properties
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@import CoreLocation;


@interface BeerEntry : NSManagedObject

// beer name string
@property (nonatomic, strong) NSString *beerName;
// beer brewer string
@property (nonatomic, strong) NSString *beerBrewer;
// beer type string
@property (nonatomic, strong) NSString *beerType;
// beer rating integer (1-10)
@property (nonatomic) int rating;
// log date NSDate
@property (nonatomic, strong) NSDate *logDate;
// location of beer CLLocation
@property (nonatomic, strong) CLLocation *location;
// entryKey for unique identification if i want to store images in the future
// for each entry
@property (nonatomic, strong) NSString *entryKey;
// ordering value for future extensibility (not currently in use)
@property (nonatomic) double orderingValue;

@end
