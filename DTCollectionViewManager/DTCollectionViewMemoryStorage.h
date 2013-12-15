//
//  DTCollectionViewMemoryStorage.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTCollectionViewStorage.h"

@interface DTCollectionViewMemoryStorage : NSObject <DTCollectionViewStorage>

/**
 Creates DTTableViewMemoryStorage with default configuration.
 */

+(instancetype)storage;

/**
 Contains array of DTTableViewSectionModel's. Every DTTableViewSectionModel contains NSMutableArray of objects - there all table view models are stored. Every DTTableViewSectionModel also contains header and footer models for sections.
 */

@property (nonatomic, strong) NSMutableArray * sections;

/**
 Delegate object, that gets notified about data storage updates. This property is automatically set by `DTTableViewController` instance, when setter for dataStorage property is called.
 */
@property (nonatomic, weak) id <DTCollectionViewDataStorageUpdating> delegate;

@end
