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

});

SPEC_END
