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
           [collection registerClass:[ModelCell class]
              forCellReuseIdentifier:@"ModelCell"
                       forModelClass:[Model class]];
        });
        
        it(@"should correctly add item", ^{
            [collection addCollectionItem:model1];
            [collection verifyCollectionItem:model1
                                 atIndexPath:[NSIndexPath indexPathForItem:0
                                                                 inSection:0]];
            [collection addCollectionItem:model2];
            [collection addCollectionItem:model3];
            
            [collection verifyCollectionItem:model2
                                 atIndexPath:[NSIndexPath indexPathForItem:1
                                                                 inSection:0]];
            [collection verifyCollectionItem:model3
                                 atIndexPath:[NSIndexPath indexPathForItem:2
                                                                 inSection:0]];
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
});

SPEC_END
