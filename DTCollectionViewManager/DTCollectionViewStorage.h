//
//  DTCollectionViewStorage.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTCollectionViewUpdate.h"


/**
 `DTTableViewDataStorageUpdating` protocol is used to transfer data storage updates to `DTTableViewController` object.
 */

@protocol DTCollectionViewDataStorageUpdating

/**
 This method transfers data storage updates to `DTTableViewController` object. Then `DTTableViewController` object is expected to perform all animations required to synchronize datasource and UI.
 
 @param update `DTTableViewUpdate` instance, that incapsulates all changes, happened in data storage.
 */
- (void)performUpdate:(DTCollectionViewUpdate *)update;

@end


@protocol DTCollectionViewStorage <NSObject>


/**
 Array of sections, conforming to DTTableViewSection protocol. Depending on data storage used, section objects may be different.
 
 @return NSArray of id <DTTableViewSection> objects.
 */

- (NSArray*)sections;

/**
 Returns collection item at concrete indexPath. This method is used for perfomance reasons. For example, when DTTableViewCoreDataStorage is used, calling objects method will fetch all the objects from fetchRequest, bu we want to fetch only one.
 
 @param indexPath indexPath of desired tableItem
 
 @return table item at desired indexPath
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

/**
 Delegate property used to transfer current data storage changes to `DTTableViewController` object. It is expected to update UI with appropriate animations.
 */

@property (nonatomic, weak) id <DTCollectionViewDataStorageUpdating> delegate;

@optional

/**
 Method to create searching data storage, based on current data storage. This method will be called automatically by `DTTableViewController` instance.
 
 @param searchString String, used to search in data storage
 
 @param searchScope Search scope for current search.
 
 @return searching data storage.
 */

- (instancetype)searchingStorageForSearchString:(NSString *)searchString
                                  inSearchScope:(NSInteger)searchScope;

/**
 Getter method for header model for current section.
 
 @param index Number of section.
 
 @return Header model for section at index.
 */
- (id)headerModelForSectionIndex:(NSInteger)index;

@end
