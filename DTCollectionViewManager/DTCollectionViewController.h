//
//  DTCollectionViewController.h
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 1/23/13.
//  Copyright (c) 2013 MLSDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTCollectionViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,retain) IBOutlet UICollectionView * collectionView;


// Search
-(int)numberOfSections;
-(NSArray *)itemsArrayForSection:(int)index;
-(id)collectionItemAtIndexPath:(NSIndexPath *)indexPath;
-(NSArray *)sectionsArray;

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;
-(void)registerSupplementaryClass:(Class)supplementaryClass
                          forKind:(NSString *)kind
                    forModelClass:(Class)modelClass;


-(NSMutableArray *)supplementaryModelsOfKind:(NSString *)kind;

-(void)addCollectionItem:(id)item;
-(void)addCollectionItems:(NSArray *)items;

-(void)addCollectionItem:(id)item toSection:(int)section;
-(void)addCollectionItems:(NSArray *)items toSection:(int)section;

-(void)removeCollectionItem:(id)item;
-(void)removeCollectionItemAtIndexPath:(NSIndexPath *)indexPath;

-(void)removeCollectionItems:(NSArray *)items;
-(void)removeCollectionItemsAtIndexPaths:(NSArray *)indexPaths;

-(void)removeAllCollectionItems;

-(void)insertItem:(id)item atIndexPath:(NSIndexPath *)indexPath;
-(void)moveItem:(id)item toIndexPath:(NSIndexPath *)indexPath;
-(void)replaceItem:(id)oldItem withItem:(id)newItem;

-(void)moveSection:(int)fromSection toSection:(int)toSection;
-(void)deleteSections:(NSIndexSet *)indexSet;

@end
