#import "DTCollectionViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(Mapping)

describe(@"DTCollectionViewController", ^{
    __block DTCollectionViewController *model;
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        
        model = [DTCollectionViewController new];
        UICollectionViewLayout * layout = [[UICollectionViewLayout alloc] init];
        model.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)
                                                  collectionViewLayout:layout];
        model.collectionView.dataSource = model;
        [model.collectionView reloadData];
    });
    
    afterEach(^{
        [UIView setAnimationsEnabled:YES];
    });
    
    describe(@"Model mapping", ^{

        it(@"should be truthy", ^{
            @(YES) should BeTruthy();
        });
    });
});

SPEC_END
