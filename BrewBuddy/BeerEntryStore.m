//
//  BeerEntryStore.m
//  BrewBuddy
//
//  Created by Kevin Stewart on 2016-03-02.
//  Copyright © 2016 Kevin Stewart. All rights reserved.
//  991 346 110
//
//  Model class to interface with Core Data store
//

#import "BeerEntryStore.h"
#import "BeerEntry.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>
@import CoreData;


@interface BeerEntryStore ()

// store of entries that are not publicly accessible
@property (nonatomic) NSMutableArray *privateEntries;
// Core Data context
@property (nonatomic, strong) NSManagedObjectContext *context;
// Core data model
@property (nonatomic, strong) NSManagedObjectModel *model;

@end

@implementation BeerEntryStore


// Creates a singleton
+ (instancetype)sharedStore
{
    static BeerEntryStore *sharedStore;
    
    // Only allow dispatch once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate]; // Can customize initializer used
    });
    
    return sharedStore;
}

// Do not allow init to be called by accident
- (instancetype)init
{
    [NSException raise:@"Singleton"
                format:@"not available"];
    return nil;
}

// real private initializer
- (instancetype)initPrivate
{
    self = [super init];
    
    if (self)
    {
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        
        // Create file path for core data
        NSString *path = self.entryArchivePath;
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        NSLog(@"StoreURL = %@", storeURL.absoluteString);
        
        NSError *error = nil;

        // Open store and throw exception if there is an error
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error])
        {
            @throw [NSException exceptionWithName:@"OpenFailure"
                                           reason:[error localizedDescription]
                                         userInfo:nil];
        }
        
        // If it worked create contet
        _context = [[NSManagedObjectContext alloc]
                    initWithConcurrencyType:NSMainQueueConcurrencyType];
        _context.persistentStoreCoordinator = psc;
        
        [self loadAllEntries];
    }
    
    return self;
}


// Return path where core data is stored
- (NSString *)entryArchivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

// Return all entries sorted by date
- (void)loadAllEntries
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *e = [NSEntityDescription entityForName:@"BeerEntry"
                                         inManagedObjectContext:self.context];
    request.entity = e;
    
    // Sort by date
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"logDate"
                                                         ascending:NO];
    request.sortDescriptors = @[sd];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:request error:&error];
    if (!result)
    {
        [NSException raise:@"Fetch Failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    // assign to private array
    self.privateEntries = [[NSMutableArray alloc] initWithArray:result];
}

// Save all changes
- (BOOL)saveChanges
{
    NSError *error;
    BOOL successful = [self.context save:&error];
    if (!successful)
    {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
    return successful;
}

// Return all entries
- (NSArray *)allEntries
{
    // Send a copy so other classes can't modify it
    return [self.privateEntries copy];
}

// Create a new entry
- (BeerEntry *)createEntry
{
    
    // Determine ordering value (not in use right now but could be used in future)
    double order;
    if (self.allEntries.count == 0)
    {
        order = 1.0;
    } else
    {
        order = [[self.privateEntries lastObject] orderingValue] + 1.0;
    }
    
    BeerEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"BeerEntry" inManagedObjectContext:self.context];
    
    // Assign default values
    entry.orderingValue = order;
    entry.rating = 5;
    entry.beerBrewer = @"Brewery";
    entry.beerName = @"Beer";
    entry.beerType = @"Pilsner";
    entry.logDate = [NSDate date];
    
    // This will be the default and will be checked as default
    entry.location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    
    // add object to entries array
    [self.privateEntries addObject:entry];
    
    return entry;
}

// Remove entry
- (void)removeEntry:(BeerEntry *)entry
{
    [self.context deleteObject:entry];
    // Must use removeObjectIdenticalTo to not base removal on memory address
    [self.privateEntries removeObjectIdenticalTo:entry];
    
}


@end
