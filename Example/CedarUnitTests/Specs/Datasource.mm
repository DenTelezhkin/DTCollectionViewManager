#import "DTCollectionViewController+VerifyItem.h"
#import "Model.h"
#import "ModelCell.h"
#import "ModelCellWithNib.h"
#import "SupplementaryViewWithNib.h"

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
            [collection registerCellClass:[ModelCellWithNib class]
                            forModelClass:[Model class]];
            [collection.collectionView reloadData];
        });
        
        it(@"should correctly add item", ^{
            [collection.memoryStorage addItem:model1];
            [collection verifyCollectionItem:model1
                                 atIndexPath:[NSIndexPath indexPathForItem:0
                                                                 inSection:0]];
            [collection.memoryStorage addItem:model2];
            [collection.memoryStorage addItem:model3];
            
            [collection verifySection:@[model1,model2,model3] withSectionNumber:0];
        });
        
        it(@"should correctly add items to different section", ^{
            [collection.memoryStorage addItem:model1 toSection:1];
            [collection.memoryStorage addItem:model2 toSection:3];
            [collection.memoryStorage addItem:model3 toSection:0];
            
            [collection numberOfSectionsInCollectionView:collection.collectionView] should equal(4);
            
            [collection verifySection:@[model1] withSectionNumber:1];
            [collection verifySection:@[model2] withSectionNumber:3];
            [collection verifySection:@[model3] withSectionNumber:0];
            [collection verifySection:@[] withSectionNumber:2];
            [collection.collectionView numberOfSections] should equal(4);
        });
        
        it(@"should correctly add items to section", ^{
            NSArray * models = @[model1,model2,model3];
            [collection.memoryStorage addItems:models];
            
            [collection verifySection:models withSectionNumber:0];
            
            [collection.collectionView numberOfSections] should equal(1);
        });
        
        it(@"should add similar items", ^{
            [collection.memoryStorage addItems:@[model1,model1,model1]];
            
            [collection verifySection:@[model1,model1,model1] withSectionNumber:0];
        });
        
        it(@"should correctly add items to sections", ^{
            NSArray * models0 = @[model1,model2];
            NSArray * models1 = @[model3,model4];
            NSArray * models3 = @[model5,model6];
            
            [collection.memoryStorage addItems:models0 toSection:0];
            [collection.memoryStorage addItems:models1 toSection:1];
            [collection.memoryStorage addItems:models3 toSection:3];
            
            [collection verifySection:models0 withSectionNumber:0];
            [collection verifySection:models1 withSectionNumber:1];
            [collection verifySection:@[] withSectionNumber:2];
            [collection verifySection:models3 withSectionNumber:3];
            
            [collection.collectionView numberOfSections] should equal(4);
        });
    });
    
    describe(@"removing items", ^{
        beforeEach(^{
            [collection registerCellClass:[ModelCellWithNib class]
                            forModelClass:[Model class]];
        });
        
        it(@"should remove item", ^{
            [collection.memoryStorage addItems:@[model1,model2,model3,model4,model5]];
            
            [collection.memoryStorage removeItem:model2];
            [collection.memoryStorage removeItem:model5];
            
            [collection verifySection:@[model1,model3,model4] withSectionNumber:0];
        });
        
        it(@"should remove last item in section", ^{
            [collection.memoryStorage addItem:model1 toSection:1];
            [collection.memoryStorage addItem:model2 toSection:0];
            [collection.memoryStorage addItem:model3 toSection:2];
            
            [collection.memoryStorage removeItem:model2];
            [collection.memoryStorage removeItem:model3];
            
            [collection verifySection:@[] withSectionNumber:0];
            [collection verifySection:@[model1] withSectionNumber:1];
            [collection verifySection:@[] withSectionNumber:2];
        });
        
        it(@"should not crash when removing absent item", ^{
            ^{
                [collection.memoryStorage removeItem:model1];
            } should_not raise_exception;
        });
        
        it(@"should remove item at indexPath", ^{
            [collection.memoryStorage addItems:@[model1,model2,model3]];
            [collection.memoryStorage addItems:@[model4,model5] toSection:1];
            
            [collection.memoryStorage removeItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
            [collection.memoryStorage removeItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
            
            [collection verifySection:@[model1,model2] withSectionNumber:0];
            [collection verifySection:@[model5] withSectionNumber:1];
        });
        
        it(@"should not crash when removing absent indexPath", ^{
            ^{
                [collection.memoryStorage addItems:@[model2,model3]];
                [collection.memoryStorage removeItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
                [collection verifySection:@[model2,model3] withSectionNumber:0];
                [collection.memoryStorage removeItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
                [collection verifySection:@[model2,model3] withSectionNumber:0];
            } should_not raise_exception;
        });
        
        it(@"should not crash when removing absent items", ^{
            ^{
                [collection.memoryStorage addItems:@[model2,model3]];
                [collection.memoryStorage removeItems:@[model3, model4]];
                [collection verifySection:@[model2] withSectionNumber:0];
            } should_not raise_exception;
        });
        
        it(@"should remove collection items", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            [collection.memoryStorage addItems:@[model3,model4] toSection:1];
            [collection.memoryStorage addItems:@[model5,model6] toSection:2];
            
            [collection.memoryStorage removeItems:@[model1,model4,model5]];
            
            [collection verifySection:@[model2] withSectionNumber:0];
            [collection verifySection:@[model3] withSectionNumber:1];
            [collection verifySection:@[model6] withSectionNumber:2];
        });
        
        it(@"should not crash when removing absent indexPath", ^{
            ^{
                [collection.memoryStorage addItems:@[model2,model3]];
                
                [collection.memoryStorage removeItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
                [collection verifySection:@[model2,model3] withSectionNumber:0];
            } should_not raise_exception;
        });
        
#warning removeAllItems
        /*
        it(@"should remove all collection items", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            [collection.memoryStorage addItems:@[model3,model4] toSection:1];
            [collection.memoryStorage addItems:@[model5,model6] toSection:2];
            
            [collection removeAllCollectionItems];
            
            [collection numberOfSections] should equal(0);
        });*/
        
    });
    
    describe(@"inserting items", ^{
        
        beforeEach(^{
            [collection registerCellClass:[ModelCellWithNib class]
                            forModelClass:[Model class]];
        });
        
        it(@"should raise when inserting to wrong indexPath", ^{
            ^{
                [collection.memoryStorage insertItem:model1
                                         toIndexPath:[NSIndexPath indexPathForItem:2
                                                                         inSection:3]];
            } should_not raise_exception;
        });
        
        it(@"should be able to insert first item", ^{
            [collection.memoryStorage insertItem:model1
                                     toIndexPath:[NSIndexPath indexPathForItem:0
                                                                     inSection:0]];
            
            [collection verifySection:@[model1] withSectionNumber:0];
        });
        
        it(@"should be able to insert last item", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            
            [collection.memoryStorage insertItem:model3
                                     toIndexPath:[NSIndexPath indexPathForItem:2
                                                                     inSection:0]];
            
            [collection verifySection:@[model1,model2,model3] withSectionNumber:0];
        });
        
        it(@"should be able to insert into non existing section", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            [collection.memoryStorage addItems:@[model3,model4] toSection:1];
            
            
            /*if ([collection iOS6]) {
                [collection.collectionView reloadData];
            }*/
            
            [collection.memoryStorage insertItem:model5
                                     toIndexPath:[NSIndexPath indexPathForItem:0
                                                                     inSection:2]];
            
            [collection verifySection:@[model1,model2]
                    withSectionNumber:0];
            [collection verifySection:@[model3,model4]
                    withSectionNumber:1];
            [collection verifySection:@[model5]
                    withSectionNumber:2];
        });
        
        it(@"should be able to insert item in different section", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            [collection.memoryStorage addItems:@[model3,model4] toSection:1];
            
            [collection.memoryStorage insertItem:model5
                                     toIndexPath:[NSIndexPath indexPathForItem:2
                                                                     inSection:0]];
            
            [collection verifySection:@[model1,model2,model5]
                    withSectionNumber:0];
            [collection verifySection:@[model3,model4]
                    withSectionNumber:1];
        });
        
        it(@"should be able to insert last item", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            [collection.memoryStorage addItems:@[model3,model4] toSection:1];
            
            [collection.memoryStorage insertItem:model5
                                     toIndexPath:[NSIndexPath indexPathForItem:2
                                                                     inSection:1]];
            
            [collection verifySection:@[model1,model2]
                    withSectionNumber:0];
            [collection verifySection:@[model3,model4,model5]
                    withSectionNumber:1];
        });
        
        it(@"should be able to insert into 2 section", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            
            /*if ([collection iOS6]) {
                [collection.collectionView reloadData];
            }*/
            
            [collection.memoryStorage insertItem:model3
                                     toIndexPath:[NSIndexPath indexPathForItem:0
                                                                     inSection:1]];
            
            [collection verifySection:@[model1,model2] withSectionNumber:0];
            [collection verifySection:@[model3] withSectionNumber:1];
        });
    });
#warning move
    /*
    describe(@"moving items", ^{
        
        beforeEach(^{
            [collection registerCellClass:[ModelCellWithNib class]
                            forModelClass:[Model class]];
        });
        

        it(@"should move item to another row", ^{
            [collection addItems:@[model1,model2,model3]];
            
            [collection moveItem:model1 toIndexPath:[NSIndexPath indexPathForItem:2
                                                                        inSection:0]];
            [collection verifySection:@[model2,model3,model1] withSectionNumber:0];
        });
        
        it(@"should move item to another empty section", ^{
            [collection.memoryStorage addItems:@[model1,model2,model3]];
            
            if ([collection iOS6]) {
                [collection.collectionView reloadData];
            }
            [collection moveItem:model3 toIndexPath:[NSIndexPath indexPathForItem:0
                                                                        inSection:1]];
            [collection verifySection:@[model1,model2] withSectionNumber:0];
            [collection verifySection:@[model3] withSectionNumber:1];
        });
        
        it(@"should move item to another section", ^{
            [collection.memoryStorage addItems:@[model1,model2,model3]];
            [collection.memoryStorage addItems:@[model4] toSection:1];
            
            [collection moveItem:model3 toIndexPath:[NSIndexPath indexPathForItem:0
                                                                        inSection:1]];
            [collection verifySection:@[model1,model2] withSectionNumber:0];
            [collection verifySection:@[model3,model4] withSectionNumber:1];
        });
        
        it(@"should not crash when moving to wrong indexPath", ^{
            [collection addItems:@[model1,model2]];
            
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
    });*/
    
    describe(@"replacing items", ^{
        
        beforeEach(^{
            [collection registerCellClass:[ModelCellWithNib class]
                            forModelClass:[Model class]];
        });
        
        it(@"should replace item", ^{
            [collection.memoryStorage addItems:@[model1,model2,model3]];
            
            [collection.memoryStorage replaceItem:model2 withItem:model4];
            
            [collection verifySection:@[model1,model4,model3] withSectionNumber:0];
        });
        
        it(@"should replace item at another section", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            [collection.memoryStorage addItems:@[model3,model4] toSection:1];
            
            [collection.memoryStorage replaceItem:model3 withItem:model5];
            
            [collection verifySection:@[model1,model2] withSectionNumber:0];
            [collection verifySection:@[model5,model4] withSectionNumber:1];
        });
        
        it(@"should not crash if source item not found", ^{
            ^{
                [collection.memoryStorage replaceItem:model1 withItem:model2];
            } should_not raise_exception;
        });
    });
    
    describe(@"moving sections", ^{
        
        beforeEach(^{
            [collection registerCellClass:[ModelCellWithNib class]
                            forModelClass:[Model class]];
        });
        
        it(@"should move section to empty section", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            
            /*if ([collection iOS6]) {
                [collection.collectionView reloadData];
            }*/
            
            [collection moveSection:0 toSection:1];
            
            [collection verifySection:@[model1,model2] withSectionNumber:1];
            [collection verifySection:@[] withSectionNumber:0];
        });
        
#warning move section
        /*
        it(@"should switch sections", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            [collection.memoryStorage addItems:@[model3,model4] toSection:1];
            
            [collection moveSection:0 toSection:1];
            
            [collection verifySection:@[model3,model4] withSectionNumber:0];
            [collection verifySection:@[model1,model2] withSectionNumber:1];
        });*/
        
        describe(@"supplementaries tests", ^{
            NSString * testKind = @"testSupplementaryKind";

            __block NSArray * section0;
            __block NSArray * section1;
            __block NSArray * section2;
            beforeEach(^{
                
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[NSNumber class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionFooter
                                         forModelClass:[NSNumber class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:testKind
                                         forModelClass:[NSNumber class]];
                section0 = @[model1,model2];
                section1 = @[model3,model4];
                section2 = @[model5,model6];
            });
            
            it(@"should move section headers", ^{
                NSString * header = UICollectionElementKindSectionHeader;
                
                [collection.memoryStorage setSupplementaries:@[@1,@2,@3] forKind:header];
                
                [collection.memoryStorage addItems:section0];
                [collection.memoryStorage addItems:section1 toSection:1];
                [collection.memoryStorage addItems:section2 toSection:2];
                
                [collection moveSection:0 toSection:2];
                
                expect([collection.memoryStorage supplementaryModelOfKind:header forSectionIndex:0]).to(equal(@2));
                expect([collection.memoryStorage supplementaryModelOfKind:header forSectionIndex:1]).to(equal(@3));
                expect([collection.memoryStorage supplementaryModelOfKind:header forSectionIndex:2]).to(equal(@1));
            });
            
            it(@"should move section footers", ^{
                NSString * footer = UICollectionElementKindSectionFooter;
                
                [collection.memoryStorage setSupplementaries:@[@1,@2,@3] forKind:footer];
                
                [collection.memoryStorage addItems:section0];
                [collection.memoryStorage addItems:section1 toSection:1];
                [collection.memoryStorage addItems:section2 toSection:2];
                
                [collection moveSection:0 toSection:2];
                
                expect([collection.memoryStorage supplementaryModelOfKind:footer forSectionIndex:0]).to(equal(@2));
                expect([collection.memoryStorage supplementaryModelOfKind:footer forSectionIndex:1]).to(equal(@3));
                expect([collection.memoryStorage supplementaryModelOfKind:footer forSectionIndex:2]).to(equal(@1));
            });
            
            it(@"should move supplementaries of other kind", ^{
                NSString * customKind = testKind;
                
                [collection.memoryStorage setSupplementaries:@[@1,@2,@3] forKind:customKind];
                
                [collection.memoryStorage addItems:section0];
                [collection.memoryStorage addItems:section1 toSection:1];
                [collection.memoryStorage addItems:section2 toSection:2];
                
                [collection moveSection:0 toSection:2];
                
                expect([collection.memoryStorage supplementaryModelOfKind:customKind forSectionIndex:0]).to(equal(@2));
                expect([collection.memoryStorage supplementaryModelOfKind:customKind forSectionIndex:1]).to(equal(@3));
                expect([collection.memoryStorage supplementaryModelOfKind:customKind forSectionIndex:2]).to(equal(@1));
            });
            
            it(@"should not crash if moving inconsistent sections", ^{
                NSString * kind = UICollectionElementKindSectionHeader;
                
                [collection.memoryStorage setSupplementaries:@[@1] forKind:kind];
                
                [collection.memoryStorage addItems:section1];
                [collection.memoryStorage addItems:section2];
#warning workaround?
                /*if ([collection iOS6]) {
                    [collection.collectionView reloadData];
                }*/
                ^{
                    [collection moveSection:0 toSection:1];
                } should_not raise_exception();
            });
        });
        
    });
    
    describe(@"deleting sections", ^{
        
        beforeEach(^{
            [collection registerCellClass:[ModelCellWithNib class]
                            forModelClass:[Model class]];
        });
        
        it(@"should delete first section", ^{
            [collection.memoryStorage addItems:@[model1,model2]];
            
            [collection.memoryStorage deleteSections:[NSIndexSet indexSetWithIndex:0]];
            
            [collection.memoryStorage.sections count] should equal(0);
        });
        
        it(@"should delete any section", ^{
            [collection.memoryStorage addItems:@[model1,model2] toSection:0];
            [collection.memoryStorage addItems:@[model3,model4] toSection:1];
            [collection.memoryStorage addItems:@[model5,model6] toSection:2];
            NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSetWithIndex:0];
            [indexSet addIndex:2];
            
            [collection.memoryStorage deleteSections:indexSet];
            
            [collection.memoryStorage.sections count] should equal(1);
            
            [collection verifySection:@[model3,model4] withSectionNumber:0];
        });
        
        describe(@"supplementaries tests", ^{
            NSString * testKind = @"testSupplementaryKind";
            
            __block NSArray * section0;
            __block NSArray * section1;
            __block NSArray * section2;
            beforeEach(^{
                
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[NSNumber class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionFooter
                                         forModelClass:[NSNumber class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:testKind
                                         forModelClass:[NSNumber class]];
                section0 = @[model1,model2];
                section1 = @[model3,model4];
                section2 = @[model5,model6];
            });
            
            it(@"should delete section headers", ^{
                NSString * header = UICollectionElementKindSectionHeader;
                [collection.memoryStorage setSupplementaries:@[@1,@2] forKind:header];
                
                [collection.memoryStorage addItems:section0];
                [collection.memoryStorage addItems:section1 toSection:1];
                
                [collection.memoryStorage deleteSections:[NSIndexSet indexSetWithIndex:0]];
                
                expect([collection.memoryStorage supplementaryModelOfKind:header forSectionIndex:0]).to(equal(@2));
            });
            
            it(@"should delete section footers", ^{
                NSString * footer = UICollectionElementKindSectionFooter;
                [collection.memoryStorage setSupplementaries:@[@1,@2] forKind:footer];
                
                [collection.memoryStorage addItems:section0];
                [collection.memoryStorage addItems:section1 toSection:1];
                
                [collection.memoryStorage deleteSections:[NSIndexSet indexSetWithIndex:0]];
                
                expect([collection.memoryStorage supplementaryModelOfKind:footer forSectionIndex:0]).to(equal(@2));
            });
            
            it(@"should delete supplementaries of other kind", ^{
                NSString * customKind = testKind;
                [collection.memoryStorage setSupplementaries:@[@1,@2] forKind:customKind];
                
                [collection.memoryStorage addItems:section0];
                [collection.memoryStorage addItems:section1 toSection:1];
                
                [collection.memoryStorage deleteSections:[NSIndexSet indexSetWithIndex:0]];
                
                expect([collection.memoryStorage supplementaryModelOfKind:customKind forSectionIndex:0]).to(equal(@2));
            });
        });

    });

});

SPEC_END
