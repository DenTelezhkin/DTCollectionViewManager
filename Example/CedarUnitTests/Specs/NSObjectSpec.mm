
using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NSObjectSpec)

describe(@"NSObject", ^{

    beforeEach(^{

    });
    
    it(@"should be truthy",^{
        @(YES) should BeTruthy();
    });
});

SPEC_END
