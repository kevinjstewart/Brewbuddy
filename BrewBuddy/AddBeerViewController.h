//
//  AddBeerViewController.h
//  BrewBuddy
//
//  Created by Kevin Stewart on 2016-03-02.
//  Copyright © 2016 Kevin Stewart. All rights reserved.
//  991 346 110
//
//  Header file with public members for AddBeerViewController
//

#import <UIKit/UIKit.h>

@class BeerEntry;

@interface AddBeerViewController : UIViewController

// Entry to display
@property (nonatomic, strong) BeerEntry *entry;
// Block that tells tableview to reload when dismissed
@property (nonatomic, copy) void (^dismissBlock)(void);
// Boolean indicating whether or not an entry is new
@property (nonatomic) BOOL isNew;

@end

