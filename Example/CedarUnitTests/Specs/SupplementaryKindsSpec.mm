#import "DTCollectionViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SupplementaryKindsSpec)

describe(@"memory storage on DTCollectionViewController", ^{

    __block DTCollectionViewController * controller = nil;
    
    beforeEach(^{
        controller = [DTCollectionViewController new];
    });
    
    it(@"should have correct supplementary kinds", ^{
        controller.memoryStorage.supplementaryHeaderKind should equal(UICollectionElementKindSectionHeader);
        controller.memoryStorage.supplementaryFooterKind should equal(UICollectionElementKindSectionFooter);
    });
    
    it(@"should have correct supplementary kinds after search", ^{
        [controller filterModelsForSearchString:@"foo"];
        [(DTMemoryStorage *)controller.searchingStorage supplementaryHeaderKind] should equal(UICollectionElementKindSectionHeader);
        [(DTMemoryStorage *)controller.searchingStorage supplementaryFooterKind] should equal(UICollectionElementKindSectionFooter);
    });
    
    it(@"should set kinds for storage",^{
        DTMemoryStorage * storage = [DTMemoryStorage new];
        controller.storage = storage;
        
        storage.supplementaryHeaderKind should equal(UICollectionElementKindSectionHeader);
        storage.supplementaryFooterKind should equal(UICollectionElementKindSectionFooter);
    });
    
    it(@"should set kinds for searching storage",^{
        DTMemoryStorage * storage = [DTMemoryStorage new];
        controller.searchingStorage = storage;
        
        storage.supplementaryHeaderKind should equal(UICollectionElementKindSectionHeader);
        storage.supplementaryFooterKind should equal(UICollectionElementKindSectionFooter);
    });
});

SPEC_END
