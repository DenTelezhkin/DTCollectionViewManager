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
-(NSMutableArray *)itemsArrayForSection:(int)index;
-(id)collectionItemAtIndexPath:(NSIndexPath *)indexPath;
-(NSMutableArray *)sectionsArray;

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;
-(void)registerSupplementaryClass:(Class)supplementaryClass
                          forKind:(NSString *)kind
                    forModelClass:(Class)modelClass;


-(NSMutableArray *)supplementaryModelsOfKind:(NSString *)kind;

// Models manipulation

-(void)addCollectionItem:(id)item;
-(void)addCollectionItems:(NSArray *)items;

-(void)addCollectionItem:(id)item toSection:(int)section;
-(void)addCollectionItems:(NSArray *)items toSection:(int)section;

@end
