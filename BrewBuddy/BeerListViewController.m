//
//  BeerListViewController.m
//  BrewBuddy
//
//  Created by Kevin Stewart on 2016-03-26.
//  Copyright © 2016 Kevin Stewart. All rights reserved.
//  991 346 110
//
//  This class is the Table View Controller that lists the beers in the app
//

#import "BeerListViewController.h"
#import "AddBeerViewController.h"
#import "BeerEntry.h"
#import "BeerEntryStore.h"

@interface BeerListViewController ()

@end

@implementation BeerListViewController

// Reloads data when view Appears
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}


#pragma mark UITableView Methods

// Performs a segue with customization when a row is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"EntryDetailSegue" sender:self];
}

// Grabs all entries and sorts them by date to populate the table view
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    
    NSArray *entries = [[BeerEntryStore sharedStore] allEntries];
    
    // Sort entries by date
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"logDate"
                                                         ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sd];
    NSArray *sortedEntries = [entries sortedArrayUsingDescriptors:sortDescriptors];
    
    BeerEntry *entry = sortedEntries[indexPath.row];

    cell.textLabel.text =
        [NSString stringWithFormat:@"%@ by %@", entry.beerName, entry.beerBrewer];
    
    // Set up proper date formatting to show in table view
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateIntervalFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateIntervalFormatterNoStyle;
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",
                                 entry.beerType,
                                 [dateFormatter stringFromDate:entry.logDate]];
    // show an error on the right in every cell
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


// Calls the model to determine how many rows there should be
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BeerEntryStore sharedStore] allEntries] count];
}


#pragma mark UIStoryboard

// Customizes the next view depending on how it was instantiated.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // If this is a new entry, tell the view controller that
    if ([segue.identifier isEqualToString:@"ModalEntrySegue"])
    {
        NSLog(@"ModalEntrySegue has been prepared for.");
        BeerEntry *newEntry = [[BeerEntryStore sharedStore] createEntry];
        UINavigationController *nav = segue.destinationViewController;
        // Must access view controller using a reference due to the segway doing
        // to a navigation controller
        AddBeerViewController *abvc = (AddBeerViewController *)nav.topViewController;
        
        abvc.entry = newEntry;
        abvc.isNew = YES;
        // Reloads data on dismiss
        abvc.dismissBlock = ^{
            [self.tableView reloadData];
        };
    }
    
    // Tells the view controller that this is an existing entry and supplies the
    // relevant entry
    else if ([segue.identifier isEqualToString:@"EntryDetailSegue"])
    {
        NSLog(@"Entry Detail Segue has been prepared for.");
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AddBeerViewController *abvc = segue.destinationViewController;
        NSArray *entries = [[BeerEntryStore sharedStore] allEntries];
        BeerEntry *selectedEntry = entries[indexPath.row];
        abvc.entry = selectedEntry;
        abvc.isNew = NO;
        abvc.dismissBlock = ^{
            [self.tableView reloadData];
        };
        
    }
}


@end
