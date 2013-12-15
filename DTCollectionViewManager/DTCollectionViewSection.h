//
//  DTCollectionViewSection.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `DTTableViewSection` protocol defines an interface for sections returned by DTTableViewDataStorage object. For `DTTableViewMemoryStorage`, `DTTableViewSectionModel` is the object, conforming to current protocol. For `DTTableViewCoreDataStorage` NSFetchedResultsController returns  `NSFetchedResultsSectionInfo` objects, that also conform to current protocol.
 */

@protocol DTCollectionViewSection <NSObject>

/**
 Array of objects in section.
 
 @return Array of objects in current section.
 */

- (NSArray *)objects;

/**
 Number of objects in current section.
 
 @return Number of objects in current section
 */

- (NSUInteger)numberOfObjects;

@end
