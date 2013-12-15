#import "DTCollectionViewMemoryStorage.h"
#import "OCMock.h"
#import "Model.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MemoryStorageSpec)

describe(@"Storage search specs", ^{
    __block DTCollectionViewMemoryStorage *storage;
    
    beforeEach(^{
        storage = [DTCollectionViewMemoryStorage storage];
        storage.delegate = [OCMockObject niceMockForClass:[DTCollectionViewController class]];
    });
    
    it(@"should correctly return item at indexPath", ^{
        [storage addItems:@[@"1",@"2"] toSection:0];
        [storage addItems:@[@"3",@"4"] toSection:1];
        
        id model = [storage itemAtIndexPath:[NSIndexPath indexPathForRow:1
                                                               inSection:1]];
        
        model should equal(@"4");
        
        model = [storage itemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        model should equal(@"1");
    });
    
    it(@"should return indexPath of tableItem", ^{
        [storage addItems:@[@"1",@"2"] toSection:0];
        [storage addItems:@[@"3",@"4"] toSection:1];
        
        NSIndexPath * indexPath = [storage indexPathForItem:@"3"];
        
        indexPath should equal([NSIndexPath indexPathForRow:0 inSection:1]);
    });
    
    it(@"should return items in section",^{
        [storage addItems:@[@"1",@"2"] toSection:0];
        [storage addItems:@[@"3",@"4"] toSection:1];
        
        NSArray * section0 = [storage itemsInSection:0];
        NSArray * section1 = [storage itemsInSection:1];
        
        section0 should equal(@[@"1",@"2"]);
        section1 should equal(@[@"3",@"4"]);
    });
    
});

describe(@"Storage Add specs", ^{
    __block DTCollectionViewMemoryStorage *storage;
    __block OCMockObject * delegate;
    
    beforeEach(^{
        delegate = [OCMockObject mockForClass:[DTCollectionViewController class]];
        storage = [DTCollectionViewMemoryStorage storage];
        storage.delegate = (id <DTCollectionViewDataStorageUpdating>)delegate;
    });
    
    it(@"should receive correct update call when adding item",
       ^{
           DTCollectionViewUpdate * update = [DTCollectionViewUpdate new];
           [update.insertedSectionIndexes addIndex:0];
           [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                      inSection:0]];
           
           [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id argument) {
               return [update isEqual:argument];
           }]];
           
           [storage addItem:@""];
           [delegate verify];
       });
    
    it(@"should receive correct update call when adding items",
       ^{
           DTCollectionViewUpdate * update = [DTCollectionViewUpdate new];
           [update.insertedSectionIndexes addIndexesInRange:{0,2}];
           [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                      inSection:1]];
           [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                      inSection:1]];
           [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:2
                                                                      inSection:1]];
           
           [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id argument) {
               return [update isEqual:argument];
           }]];
           
           [storage addItems:@[@"1",@"2",@"3"] toSection:1];
           [delegate verify];
       });
});

describe(@"Storage edit specs", ^{
    __block DTCollectionViewMemoryStorage *storage;
    __block OCMockObject * delegate;
    __block Model * acc1;
    __block Model * acc2;
    __block Model * acc3;
    __block Model * acc4;
    __block Model * acc5;
    __block Model * acc6;
    
    beforeEach(^{
        delegate = [OCMockObject niceMockForClass:[DTCollectionViewController class]];
        storage = [DTCollectionViewMemoryStorage storage];
        storage.delegate = (id <DTCollectionViewDataStorageUpdating>)delegate;
        
        acc1 = [Model new];
        acc2 = [Model new];
        acc3 = [Model new];
        acc4 = [Model new];
        acc5 = [Model new];
        acc6 = [Model new];
    });
    
    it(@"should insert items", ^{
        [storage addItems:@[acc2,acc4,acc6]];
        [storage addItem:acc5 toSection:1];
        
        DTCollectionViewUpdate * update = [DTCollectionViewUpdate new];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:2
                                                                   inSection:0]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage insertItem:acc1 toIndexPath:[storage indexPathForItem:acc6]];
        
        [delegate verify];
        
        update = [DTCollectionViewUpdate new];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                   inSection:1]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage insertItem:acc3 toIndexPath:[storage indexPathForItem:acc5]];
        
        [delegate verify];
    });
    
    it(@"should reload items", ^{
        
        [storage addItems:@[acc2,acc4,acc6]];
        
        DTCollectionViewUpdate * update = [DTCollectionViewUpdate new];
        [update.updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage reloadItem:acc4];
        
        [delegate verify];
    });
    
    it(@"should replace items", ^{
        
        [storage addItems:@[acc2,acc4,acc6]];
        
        DTCollectionViewUpdate * update = [DTCollectionViewUpdate new];
        [update.updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage replaceItem:acc4 withItem:acc5];
        
        [delegate verify];
    });
    
    it(@"should remove item", ^{
        [storage addItems:@[acc2,acc4,acc6]];
        [storage addItem:acc5 toSection:1];
        
        DTCollectionViewUpdate * update = [DTCollectionViewUpdate new];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                  inSection:0]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage removeItem:acc2];
        [delegate verify];
        
        update = [DTCollectionViewUpdate new];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                  inSection:1]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage removeItem:acc5];
        [delegate verify];
    });
    
    it(@"should remove items", ^{
        [storage addItems:@[acc1,acc3] toSection:0];
        [storage addItems:@[acc2,acc4] toSection:1];
        
        DTCollectionViewUpdate * update = [DTCollectionViewUpdate new];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                  inSection:0]];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:1]];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage removeItems:@[acc1,acc4,acc3,acc5]];
        [delegate verify];
        
        [[storage itemsInSection:0] count] should equal(0);
        [[storage itemsInSection:1] count] should equal(1);
    });
    
    it(@"should delete sections", ^{
        [storage addItem:acc1];
        [storage addItem:acc2 toSection:1];
        [storage addItem:acc3 toSection:2];
        
        DTCollectionViewUpdate * update = [DTCollectionViewUpdate new];
        [update.deletedSectionIndexes addIndex:1];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage deleteSections:[NSIndexSet indexSetWithIndex:1]];
        [delegate verify];
        
        [[storage sections] count] should equal(2);
    });
    
    
    /*it(@"should set section header models", ^{
        [storage setSectionHeaderModels:@[@"1",@"2",@"3"]];
        
        [[storage sections] count] should equal(3);
        
        [[storage sections][0] headerModel] should equal(@"1");
        [[storage sections][1] headerModel] should equal(@"2");
        [[storage sections][2] headerModel] should equal(@"3");
    });
    
    it(@"should set section footer models", ^{
        [storage setSectionFooterModels:@[@"1",@"2",@"3"]];
        
        [[storage sections] count] should equal(3);
        
        [[storage sections][0] footerModel] should equal(@"1");
        [[storage sections][1] footerModel] should equal(@"2");
        [[storage sections][2] footerModel] should equal(@"3");
    });
    
    it(@"should empty section headers if nil passed", ^{
        [storage setSectionHeaderModels:@[@"1",@"2",@"3"]];
        
        [storage setSectionHeaderModels:nil];
        
        DTTableViewSectionModel * section2 = [storage sectionAtIndex:1];
        
        expect(section2.headerModel == nil).to(BeTruthy());
    });
    
    it(@"should empty section headers if nil passed", ^{
        [storage setSectionHeaderModels:@[@"1",@"2",@"3"]];
        
        [storage setSectionHeaderModels:@[]];
        
        DTTableViewSectionModel * section2 = [storage sectionAtIndex:1];
        expect(section2.headerModel == nil).to(BeTruthy());
    });
    
    it(@"should empty section headers if nil passed", ^{
        [storage setSectionFooterModels:@[@"1",@"2",@"3"]];
        
        [storage setSectionFooterModels:nil];
        
        DTTableViewSectionModel * section2 = [storage sectionAtIndex:1];
        expect(section2.footerModel == nil).to(BeTruthy());
    });
    
    it(@"should empty section headers if nil passed", ^{
        [storage setSectionFooterModels:@[@"1",@"2",@"3"]];
        
        [storage setSectionFooterModels:@[]];
        
        DTTableViewSectionModel * section2 = [storage sectionAtIndex:1];
        expect(section2.footerModel == nil).to(BeTruthy());
    });*/
});

SPEC_END
