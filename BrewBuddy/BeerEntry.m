//
//  Beer.m
//  BrewBuddy
//
//  Created by Kevin Stewart on 2016-03-02.
//  Copyright © 2016 Kevin Stewart. All rights reserved.
//  991 346 110
//
//  Core data model for entries
//

#import "BeerEntry.h"

@implementation BeerEntry

// dynamic properties for core data model
@dynamic beerName;
@dynamic beerBrewer;
@dynamic beerType;
@dynamic rating;
@dynamic logDate;
@dynamic location;
@dynamic entryKey;
@dynamic orderingValue;

// When a class is instantiated using core data
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    // Create a unique identifier
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    self.entryKey = key;
}

@end
