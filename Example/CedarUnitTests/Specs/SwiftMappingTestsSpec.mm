#import "DTCollectionViewController.h"
#import "Tests-Swift.h"
#import "DTMemoryStorage+DTCollectionViewManagerAdditions.h"
#import "DTMemoryStorage+UpdateWithoutAnimations.h"
#import "ModelCellWithNib.h"
#import "Model.h"
#import "SwiftProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SwiftMappingTestsSpec)

describe(@"SwiftMappingTests", ^{
    __block DTCollectionViewController *collection;
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        [CATransaction setDisableActions:YES];
        
        collection = [DTCollectionViewController new];
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.headerReferenceSize = CGSizeMake(200, 300);
        layout.footerReferenceSize = CGSizeMake(200, 300);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        collection.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)
                                                       collectionViewLayout:layout];
        collection.collectionView.dataSource = collection;
        collection.collectionView.delegate = collection;
        
        [collection registerCellClass:[ModelCellWithNib class] forModelClass:[Model class]];
    });
    
    afterEach(^{
        [UIView setAnimationsEnabled:YES];
        [CATransaction setDisableActions:NO];
    });
    
    it(@"should accept swift cell", ^{
        [collection registerCellClass:[SwiftCollectionViewCell class]
                        forModelClass:[NSString class]];
        [collection.memoryStorage addItem:@""];
        [collection.collectionView reloadData];
        
        SwiftCollectionViewCell * cell = (id)[collection collectionView:collection.collectionView
                                             cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        cell.titleLabel.text should equal(@"Foo");
    });
    
    it(@"should accept swift header", ^{
        [collection registerSupplementaryClass:[SwiftHeaderView class]
                                       forKind:UICollectionElementKindSectionHeader
                                 forModelClass:[NSString class]];
        
        [collection.memoryStorage updateWithoutAnimations:^{
            [collection.memoryStorage setSupplementaries:@[@""]
                                                 forKind:UICollectionElementKindSectionHeader];
            [collection.memoryStorage addItem:[Model new]];
        }];
        
        [collection.collectionView reloadData];
        [collection.collectionView performBatchUpdates:nil completion:nil];
        
        id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
        SwiftHeaderView * view = (id)[datasource collectionView:collection.collectionView
                              viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                                    atIndexPath:[NSIndexPath indexPathForItem:0
                                                                                    inSection:0]];
        view.titleLabel.text should equal(@"Bar");
    });
    
    it(@"should accept swift footer", ^{
        [collection registerSupplementaryClass:[SwiftHeaderView class]
                                       forKind:UICollectionElementKindSectionFooter
                                 forModelClass:[NSString class]];
        
        [collection.memoryStorage updateWithoutAnimations:^{
            [collection.memoryStorage setSupplementaries:@[@""]
                                                 forKind:UICollectionElementKindSectionFooter];
            [collection.memoryStorage addItem:[Model new]];
        }];
        
        [collection.collectionView reloadData];
        [collection.collectionView performBatchUpdates:nil completion:nil];
        
        id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
        SwiftHeaderView * view = (id)[datasource collectionView:collection.collectionView
                              viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                                    atIndexPath:[NSIndexPath indexPathForItem:0
                                                                                    inSection:0]];
        view.titleLabel.text should equal(@"Bar");
    });
    
});

describe(@"Swift storyboard", ^{
    __block SwiftProvider * provider = nil;
    __block SwiftStoryboardViewController * controller = nil;
    
    beforeEach(^{
        provider = [SwiftProvider new];
        controller = provider.controller;
        [controller view];
        
        [controller registerCellClass:[SwiftStoryboardCell class]
                        forModelClass:[NSString class]];
        [controller registerSupplementaryClass:[SwiftStoryboardHeader class]
                                       forKind:UICollectionElementKindSectionHeader
                                 forModelClass:[NSNumber class]];
        [controller registerSupplementaryClass:[SwiftFooterView class]
                                       forKind:UICollectionElementKindSectionFooter
                                 forModelClass:[NSString class]];
        
    });
    
    it(@"should accept cells", ^{
        [controller.memoryStorage addItem:@""];
        SwiftStoryboardCell * cell = (id) [controller collectionView:controller.collectionView
                                                cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0
                                                                        
                                                                                           inSection:0]];
        cell.titleLabel.text should equal(@"Swift Cell");
    });
    
    it(@"should accept swift header", ^{
        [controller.memoryStorage updateWithoutAnimations:^{
            [controller.memoryStorage setSupplementaries:@[@5]
                                                 forKind:UICollectionElementKindSectionHeader];
            [controller.memoryStorage addItem:@""];
        }];
        
        [controller.collectionView reloadData];
        [controller.collectionView performBatchUpdates:nil completion:nil];
        
        id <UICollectionViewDataSource> datasource = controller.collectionView.dataSource;
        SwiftStoryboardHeader * view = (id)[datasource collectionView:controller.collectionView
                              viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                                    atIndexPath:[NSIndexPath indexPathForItem:0
                                                                                    inSection:0]];
        view.titleLabel.text should equal(@"Swift Header View");
    });
    
    it(@"should accept swift footer", ^{
        [controller registerSupplementaryClass:[SwiftFooterView class]
                                       forKind:UICollectionElementKindSectionFooter
                                 forModelClass:[NSString class]];
        
        [controller.memoryStorage updateWithoutAnimations:^{
            [controller.memoryStorage setSupplementaries:@[@"safsaf"]
                                                 forKind:UICollectionElementKindSectionFooter];
            [controller.memoryStorage addItem:@""];
        }];
        
        [controller.collectionView reloadData];
        [controller.collectionView performBatchUpdates:nil completion:nil];
        
        id <UICollectionViewDataSource> datasource = controller.collectionView.dataSource;
        SwiftFooterView * view = (id)[datasource collectionView:controller.collectionView
                              viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                                    atIndexPath:[NSIndexPath indexPathForItem:0
                                                                                    inSection:0]];
        view.titleLabel.text should equal(@"Swift Footer View");
    });
});

SPEC_END
