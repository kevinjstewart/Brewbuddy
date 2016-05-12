//
//  BeerEntryStore.h
//  BrewBuddy
//
//  Created by Kevin Stewart on 2016-03-02.
//  Copyright © 2016 Kevin Stewart. All rights reserved.
//  991 346 110
//
//  Header file for BeerEntryStore class
//

#import <Foundation/Foundation.h>
#import "BeerEntry.h"
#import <UIKit/UIKit.h>

@interface BeerEntryStore : NSObject

// public method to get all entries
@property (nonatomic, readonly, copy) NSArray *allEntries;

// returns singleton to access
+ (instancetype)sharedStore;

// method to save changes that returns the success status
- (BOOL)saveChanges;
// creates and returns a beerentry
- (BeerEntry *)createEntry;
// removes an entry
- (void)removeEntry:(BeerEntry *)entry;

@end
