//
//  DTCollectionViewMemoryStorage.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTCollectionViewStorage.h"

@interface DTMemoryStorage : NSObject <DTCollectionViewStorage>

/**
 Creates DTTableViewMemoryStorage with default configuration.
 */

+(instancetype)storage;

/**
 Contains array of DTCollectionViewSectionModel's. Every DTCollectionViewSectionModel contains NSMutableArray of objects - there all table view models are stored. Every DTTableViewSectionModel also contains header and footer models for sections.
 */

@property (nonatomic, strong) NSMutableArray * sections;

/**
 Delegate object, that gets notified about data storage updates. This property is automatically set by `DTTableViewController` instance, when setter for dataStorage property is called.
 */
@property (nonatomic, weak) id <DTCollectionViewDataStorageUpdating> delegate;

-(void)addItem:(NSObject *)item;

-(void)addItem:(NSObject *)item toSection:(NSInteger)sectionNumber;

-(void)addItems:(NSArray *)items;

-(void)addItems:(NSArray *)items toSection:(NSInteger)sectionNumber;

-(void)insertItem:(NSObject *)item toIndexPath:(NSIndexPath *)indexPath;

-(void)reloadItem:(NSObject *)item;

- (void)removeItem:(NSObject *)item;

- (void)removeItems:(NSArray *)items;

- (void)replaceItem:(NSObject *)itemToReplace
           withItem:(NSObject *)replacingItem;

-(void)deleteSections:(NSIndexSet *)indexSet;


-(NSArray *)itemsInSection:(NSInteger)sectionNumber;

-(id)itemAtIndexPath:(NSIndexPath *)indexPath;

-(NSIndexPath *)indexPathForItem:(NSObject *)item;

@end
