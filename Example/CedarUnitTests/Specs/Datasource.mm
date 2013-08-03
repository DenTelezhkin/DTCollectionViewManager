#import "DTCollectionViewController+VerifyItem.h"
#import "Model.h"
#import "ModelCell.h"
#import "ModelCellWithNib.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(Datasource)

describe(@"Datasource specs", ^{
    
    __block DTCollectionViewController *collection;
    __block Model * model1;
    __block Model * model2;
    __block Model * model3;
    __block Model * model4;
    __block Model * model5;
    __block Model * model6;
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        
        collection = [DTCollectionViewController new];
        UICollectionViewLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        collection.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)
                                                       collectionViewLayout:layout];
        collection.collectionView.dataSource = collection;
        [collection.collectionView reloadData];
        
        model1 = [Model new];
        model2 = [Model new];
        model3 = [Model new];
        model4 = [Model new];
        model5 = [Model new];
        model6 = [Model new];
        
    });
    
    afterEach(^{
        [UIView setAnimationsEnabled:YES];
    });
    
    describe(@"adding items", ^{
       
        beforeEach(^{
            [collection registerCellClass:[ModelCell class]
                            forModelClass:[Model class]];
        });
        
        it(@"should correctly add item", ^{
            [collection addCollectionItem:model1];
            [collection verifyCollectionItem:model1
                                 atIndexPath:[NSIndexPath indexPathForItem:0
                                                                 inSection:0]];
            [collection addCollectionItem:model2];
            [collection addCollectionItem:model3];
            
            [collection verifySection:@[model1,model2,model3] withSectionNumber:0];
        });
        
        it(@"should correctly add items to different section", ^{
            [collection addCollectionItem:model1 toSection:1];
            [collection addCollectionItem:model2 toSection:3];
            [collection addCollectionItem:model3 toSection:0];
            
            [collection numberOfSectionsInCollectionView:collection.collectionView] should equal(4);
            
            [collection verifySection:@[model1] withSectionNumber:1];
            [collection verifySection:@[model2] withSectionNumber:3];
            [collection verifySection:@[model3] withSectionNumber:0];
            [collection verifySection:@[] withSectionNumber:2];
            [collection.collectionView numberOfSections] should equal(4);
        });
        
        it(@"should correctly add items to section", ^{
            NSArray * models = @[model1,model2,model3];
            [collection addCollectionItems:models];
            
            [collection verifySection:models withSectionNumber:0];
            
            [collection.collectionView numberOfSections] should equal(1);
        });
        
        it(@"should add similar items", ^{
            [collection addCollectionItems:@[model1,model1,model1]];
            
            [collection verifySection:@[model1,model1,model1] withSectionNumber:0];
        });
        
        it(@"should correctly add items to sections", ^{
            NSArray * models0 = @[model1,model2];
            NSArray * models1 = @[model3,model4];
            NSArray * models3 = @[model5,model6];
            
            [collection addCollectionItems:models0 toSection:0];
            [collection addCollectionItems:models1 toSection:1];
            [collection addCollectionItems:models3 toSection:3];
            
            [collection verifySection:models0 withSectionNumber:0];
            [collection verifySection:models1 withSectionNumber:1];
            [collection verifySection:@[] withSectionNumber:2];
            [collection verifySection:models3 withSectionNumber:3];
            
            [collection.collectionView numberOfSections] should equal(4);
        });
    });
    
    describe(@"supplementary models", ^{
       
        it(@"should have empty headers", ^{
            NSMutableArray * headers = [collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter];
            headers should_not be_nil;
            
            headers should be_empty;
        });
        
        it(@"should have empty footers", ^{
            NSMutableArray * footers = [collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter];
            
            footers should_not be_nil;
            footers should be_empty;
        });
        
        it(@"should be empty for another kind of supplementaries", ^{
            NSMutableArray * aliens = [collection supplementaryModelsOfKind:@"Alien"];
            
            aliens should_not be_nil;
            aliens should be_empty;
        });
    });
    
    describe(@"removing items", ^{
        beforeEach(^{
            [collection registerCellClass:[ModelCell class]
                            forModelClass:[Model class]];
        });
        
        it(@"should remove item", ^{
            [collection addCollectionItems:@[model1,model2,model3,model4,model5]];
            
            [collection removeCollectionItem:model2];
            [collection removeCollectionItem:model5];
            
            [collection verifySection:@[model1,model3,model4] withSectionNumber:0];
        });
        
        it(@"should remove last item in section", ^{
            [collection addCollectionItem:model1 toSection:1];
            [collection addCollectionItem:model2 toSection:0];
            [collection addCollectionItem:model3 toSection:2];
            
            [collection removeCollectionItem:model2];
            [collection removeCollectionItem:model3];
            
            [collection verifySection:@[] withSectionNumber:0];
            [collection verifySection:@[model1] withSectionNumber:1];
            [collection verifySection:@[] withSectionNumber:2];
        });
        
        it(@"should not crash when removing absent item", ^{
            ^{
                [collection removeCollectionItem:model1];
            } should_not raise_exception;
        });
        
        it(@"should not crash when removing absent items", ^{
            ^{
                [collection addCollectionItems:@[model2,model3]];
                [collection removeCollectionItems:@[model3, model4]];
                [collection verifySection:@[model2] withSectionNumber:0];
            } should_not raise_exception;
        });
        
        it(@"should remove collection items", ^{
            [collection addCollectionItems:@[model1,model2]];
            [collection addCollectionItems:@[model3,model4] toSection:1];
            [collection addCollectionItems:@[model5,model6] toSection:2];
            
            [collection removeCollectionItems:@[model1,model4,model5]];
            
            [collection verifySection:@[model2] withSectionNumber:0];
            [collection verifySection:@[model3] withSectionNumber:1];
            [collection verifySection:@[model6] withSectionNumber:2];
        });
        
        it(@"should remove all collection items", ^{
            [collection addCollectionItems:@[model1,model2]];
            [collection addCollectionItems:@[model3,model4] toSection:1];
            [collection addCollectionItems:@[model5,model6] toSection:2];
            
            [collection removeAllCollectionItems];
            
            [collection numberOfSections] should equal(0);
        });
        
    });
    
    describe(@"inserting items", ^{
        
        beforeEach(^{
            [collection registerCellClass:[ModelCell class]
                            forModelClass:[Model class]];
        });
        
        it(@"should raise when inserting to wrong indexPath", ^{
            ^{
                [collection insertItem:model1
                           atIndexPath:[NSIndexPath indexPathForItem:2 inSection:3]];
            } should_not raise_exception;
        });
        
        it(@"should be able to insert first item", ^{
            [collection insertItem:model1
                       atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            
            [collection verifySection:@[model1] withSectionNumber:0];
        });
        
        it(@"should be able to insert last item", ^{
            [collection addCollectionItems:@[model1,model2]];
            
            [collection insertItem:model3
                       atIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
            
            [collection verifySection:@[model1,model2,model3] withSectionNumber:0];
        });
        
        it(@"should be able to insert into non existing section", ^{
            [collection addCollectionItems:@[model1,model2]];
            [collection addCollectionItems:@[model3,model4] toSection:1];
            
            [collection insertItem:model5
                       atIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
            
            [collection verifySection:@[model1,model2]
                    withSectionNumber:0];
            [collection verifySection:@[model3,model4]
                    withSectionNumber:1];
            [collection verifySection:@[model5]
                    withSectionNumber:2];
        });
        
        it(@"should be able to insert item in different section", ^{
            [collection addCollectionItems:@[model1,model2]];
            [collection addCollectionItems:@[model3,model4] toSection:1];
            
            [collection insertItem:model5
                       atIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
            
            [collection verifySection:@[model1,model2,model5]
                    withSectionNumber:0];
            [collection verifySection:@[model3,model4]
                    withSectionNumber:1];
        });
        
        it(@"should be able to insert last item", ^{
            [collection addCollectionItems:@[model1,model2]];
            [collection addCollectionItems:@[model3,model4] toSection:1];
            
            [collection insertItem:model5
                       atIndexPath:[NSIndexPath indexPathForItem:2 inSection:1]];
            
            [collection verifySection:@[model1,model2]
                    withSectionNumber:0];
            [collection verifySection:@[model3,model4,model5]
                    withSectionNumber:1];
        });
        
        it(@"should be able to insert into 2 section", ^{
            [collection addCollectionItems:@[model1,model2]];
            
            [collection insertItem:model3 atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
            
            [collection verifySection:@[model1,model2] withSectionNumber:0];
            [collection verifySection:@[model3] withSectionNumber:1];
        });
    });
    
    describe(@"moving items", ^{
        
        beforeEach(^{
            [collection registerCellClass:[ModelCell class]
                            forModelClass:[Model class]];
        });
        
        it(@"should move item to another row", ^{
            [collection addCollectionItems:@[model1,model2,model3]];
            
            [collection moveItem:model1 toIndexPath:[NSIndexPath indexPathForItem:2
                                                                        inSection:0]];
            [collection verifySection:@[model2,model3,model1] withSectionNumber:0];
        });
        
        it(@"should move item to another empty section", ^{
            [collection addCollectionItems:@[model1,model2,model3]];
            
            [collection moveItem:model3 toIndexPath:[NSIndexPath indexPathForItem:0
                                                                        inSection:1]];
            [collection verifySection:@[model1,model2] withSectionNumber:0];
            [collection verifySection:@[model3] withSectionNumber:1];
        });
        
        it(@"should move item to another section", ^{
            [collection addCollectionItems:@[model1,model2,model3]];
            [collection addCollectionItems:@[model4] toSection:1];
            
            [collection moveItem:model3 toIndexPath:[NSIndexPath indexPathForItem:0
                                                                        inSection:1]];
            [collection verifySection:@[model1,model2] withSectionNumber:0];
            [collection verifySection:@[model3,model4] withSectionNumber:1];
        });
        
        it(@"should not crash when moving to wrong indexPath", ^{
            [collection addCollectionItems:@[model1,model2]];
            
            ^{
                [collection moveItem:model2
                         toIndexPath:[NSIndexPath indexPathForItem:4 inSection:3]];
            } should_not raise_exception;
        });
        
        it(@"should not crash when moving non existing item", ^{
            ^{
                [collection moveItem:model1
                         toIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            } should_not raise_exception;
        });
    });
    
    describe(@"replacing items", ^{
        
        beforeEach(^{
            [collection registerCellClass:[ModelCell class]
                            forModelClass:[Model class]];
        });
        
        it(@"should replace item", ^{
            [collection addCollectionItems:@[model1,model2,model3]];
            
            [collection replaceItem:model2 withItem:model4];
            
            [collection verifySection:@[model1,model4,model3] withSectionNumber:0];
        });
        
        it(@"should replace item at another section", ^{
            [collection addCollectionItems:@[model1,model2]];
            [collection addCollectionItems:@[model3,model4] toSection:1];
            
            [collection replaceItem:model3 withItem:model5];
            
            [collection verifySection:@[model1,model2] withSectionNumber:0];
            [collection verifySection:@[model5,model4] withSectionNumber:1];
        });
        
        it(@"should not crash if source item not found", ^{
            ^{
                [collection replaceItem:model1 withItem:model2];
            } should_not raise_exception;
        });
    });
    
    describe(@"moving sections", ^{
        
        beforeEach(^{
            [collection registerCellClass:[ModelCell class]
                            forModelClass:[Model class]];
        });
        
        it(@"should move section to empty section", ^{
            [collection addCollectionItems:@[model1,model2]];
            
            [collection moveSection:0 toSection:1];
            
            [collection verifySection:@[model1,model2] withSectionNumber:1];
            [collection verifySection:@[] withSectionNumber:0];
        });
        
        it(@"should switch sections", ^{
            [collection addCollectionItems:@[model1,model2]];
            [collection addCollectionItems:@[model3,model4] toSection:1];
            
            [collection moveSection:0 toSection:1];
            
            [collection verifySection:@[model3,model4] withSectionNumber:0];
            [collection verifySection:@[model1,model2] withSectionNumber:1];
        });
    });
    
    describe(@"deleting sections", ^{
        
        beforeEach(^{
            [collection registerCellClass:[ModelCell class]
                            forModelClass:[Model class]];
        });
        
        it(@"should delete first section", ^{
            [collection addCollectionItems:@[model1,model2]];
            
            [collection deleteSections:[NSIndexSet indexSetWithIndex:0]];
            
            [collection numberOfSections] should equal(0);
        });
        
        it(@"should delete any section", ^{
            [collection addCollectionItems:@[model1,model2] toSection:0];
            [collection addCollectionItems:@[model3,model4] toSection:1];
            [collection addCollectionItems:@[model5,model6] toSection:2];
            NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSetWithIndex:0];
            [indexSet addIndex:2];
            
            [collection deleteSections:indexSet];
            
            [collection numberOfSections] should equal(1);
            
            [collection verifySection:@[model3,model4] withSectionNumber:0];
        });
    });

});

SPEC_END
