#import "DTCollectionViewController.h"
#import "Model.h"
#import "ModelCell.h"
#import "ModelCellWithNib.h"
#import "SupplementaryViewWithNib.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(Mapping)

describe(@"Mapping tests", ^{
    __block DTCollectionViewController *collection;
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        
        collection = [DTCollectionViewController new];
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.headerReferenceSize = CGSizeMake(200, 300);
        layout.footerReferenceSize = CGSizeMake(200, 300);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        collection.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)
                                                       collectionViewLayout:layout];
        collection.collectionView.dataSource = collection;
        collection.collectionView.delegate = collection;
        [collection.collectionView reloadData];
    });
    
    afterEach(^{
        [UIView setAnimationsEnabled:YES];
    });
    
    describe(@"cell mapping", ^{
        
        it(@"should be able to register cell nib", ^{
            [collection registerCellClass:[ModelCellWithNib class] forModelClass:[Model class]];
            [collection addItem:[[Model new] autorelease]];
            
            ModelCellWithNib * cell = (ModelCellWithNib *)[collection.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0
                                                                                                                inSection:0]];
            [cell class] should equal([ModelCellWithNib class]);
            
            cell.inittedWithFrame should_not BeTruthy();
            cell.awakenFromNib should BeTruthy();
        });
        
        it(@"should not be able to register wrong class", ^{
            ^{
                [collection registerCellClass:[NSString class]
                                forModelClass:[Model class]];
            } should raise_exception();
        });
        
        it(@"should not be able to register class not supporting model transfer", ^{
            ^{
                [collection registerCellClass:[UICollectionViewCell class]
                                forModelClass:[Model class]];
            } should raise_exception();
        });
    });
    
    describe(@"supplementary mapping", ^{
       
        beforeEach(^{
            [collection registerCellClass:[ModelCellWithNib class] forModelClass:[Model class]];
            [collection addItem:[[Model new] autorelease]];
        });
        
        it(@"should be able to register supplementary header nib class", ^{
            [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                           forKind:UICollectionElementKindSectionHeader
                                     forModelClass:[Model class]];
            [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader]
             addObject:[[Model new] autorelease]];
            id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
            UIView * view = [datasource collectionView:collection.collectionView
                     viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                           atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            SupplementaryView * header = (SupplementaryView *) view;
            [header class] should equal([SupplementaryViewWithNib class]);
            header.inittedWithFrame should_not BeTruthy();
            header.awakenFromNib should BeTruthy();
        });
        
        it(@"should be able to register supplementary footer nib class", ^{
            [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                           forKind:UICollectionElementKindSectionFooter
                                     forModelClass:[Model class]];
            [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter]
             addObject:[[Model new] autorelease]];
            id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
            UIView * view = [datasource collectionView:collection.collectionView
                     viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                           atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            SupplementaryView * header = (SupplementaryView *) view;
            [header class] should equal([SupplementaryViewWithNib class]);
            header.inittedWithFrame should_not BeTruthy();
            header.awakenFromNib should BeTruthy();
        });
        
        it(@"should not be able to register wrong class", ^{
            ^{
                [collection registerSupplementaryClass:[NSString class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[Model class]];
            } should raise_exception();
        });
        
        it(@"should not be able to register class not supporting model transfer", ^{
            ^{
                [collection registerSupplementaryClass:[UICollectionReusableView class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[Model class]];
            } should raise_exception();
        });
    });
    
    describe(@"Foundation class clusters", ^{
     
        beforeEach(^{
            [collection registerCellClass:[ModelCellWithNib class] forModelClass:[Model class]];
            [collection addItem:[[Model new] autorelease]];
        });
        
        describe(@"NSString", ^{
            
            beforeEach(^{
                [collection registerCellClass:[ModelCellWithNib class]
                               forModelClass:[NSString class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[NSString class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionFooter
                                         forModelClass:[NSString class]];
            });
            
            it(@"should accept constant strings", ^{
                ^{
                    [collection addItem:@""];
                } should_not raise_exception;
            });
            
            it(@"should accept non-empty strings", ^{
                ^{
                    [collection addItem:@"not empty"];
                } should_not raise_exception;
            });
            
            it(@"should accept mutable string", ^{
                ^{
                    NSMutableString * string = [[NSMutableString alloc] initWithString:@"first"];
                    [string appendString:@",second"];
                    [collection addItem:string];
                } should_not raise_exception;
            });
            
            it(@"should accept NSString header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:@"foo"];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSString footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:@"foo"];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
        });
        
        describe(@"NSMutableString", ^{
            
            beforeEach(^{
                [collection registerCellClass:[ModelCellWithNib class]
                                forModelClass:[NSMutableString class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[NSMutableString class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionFooter
                                         forModelClass:[NSMutableString class]];
            });
            
            it(@"should accept constant strings", ^{
                ^{
                    [collection addItem:@""];
                } should_not raise_exception;
            });
            
            it(@"should accept non-empty strings", ^{
                ^{
                    [collection addItem:@"not empty"];
                } should_not raise_exception;
            });
            
            it(@"should accept mutable string", ^{
                ^{
                    NSMutableString * string = [[NSMutableString alloc] initWithString:@"first"];
                    [string appendString:@",second"];
                    [collection addItem:string];
                } should_not raise_exception;
            });
            
            it(@"should accept NSString header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:@"foo"];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSString footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:@"foo"];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
        });
        
        describe(@"NSNumber", ^{
            
            beforeEach(^{
                [collection registerCellClass:[ModelCellWithNib class]
                                forModelClass:[NSNumber class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[NSNumber class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionFooter
                                         forModelClass:[NSNumber class]];
            });
            
            it(@"should accept nsnumber for cells", ^{
                ^{
                    [collection addItem:@5];
                } should_not raise_exception;
            });
            
            it(@"should accept bool number for cells", ^{
                ^{
                    [collection addItem:@YES];
                } should_not raise_exception;
            });
            
            it(@"should accept number for header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:@5];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept number for footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:@5];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept BOOL for header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:@YES];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept bool for footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:@YES];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
        });
        
        describe(@"NSDictionary", ^{
            
            beforeEach(^{
                [collection registerCellClass:[ModelCellWithNib class]
                                forModelClass:[NSDictionary class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[NSDictionary class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionFooter
                                         forModelClass:[NSDictionary class]];
            });
            
            it(@"should accept NSDictionary for cells", ^{
                ^{
                    [collection addItem:@{@1:@2}];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for cells", ^{
                ^{
                    [collection addItem:[[@{@1:@2} mutableCopy] autorelease]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSDictionary for header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:@{}];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSDictionary for footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:@{}];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:[[@{} mutableCopy] autorelease]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:[[@{} mutableCopy] autorelease]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
        });
        
        describe(@"NSMutableDictionary", ^{
            
            beforeEach(^{
                [collection registerCellClass:[ModelCellWithNib class]
                                forModelClass:[NSMutableDictionary class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[NSMutableDictionary class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionFooter
                                         forModelClass:[NSMutableDictionary class]];
            });
            
            
            it(@"should accept NSDictionary for cells", ^{
                ^{
                    [collection addItem:@{@1:@2}];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for cells", ^{
                ^{
                    [collection addItem:[[@{@1:@2} mutableCopy] autorelease]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSDictionary for header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:@{}];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSDictionary for footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:@{}];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:[[@{} mutableCopy] autorelease]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:[[@{} mutableCopy] autorelease]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
        });
        
        describe(@"NSArray", ^{
            
            beforeEach(^{
                [collection registerCellClass:[ModelCellWithNib class]
                                forModelClass:[NSArray class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[NSArray class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionFooter
                                         forModelClass:[NSArray class]];
            });
            
            it(@"should accept NSArray for cells", ^{
                ^{
                    [collection addItem:@[]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for cells", ^{
                ^{
                    [collection addItem:[[@[] mutableCopy] autorelease]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSArray for header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:@[]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:[[@[] mutableCopy] autorelease]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSArray for footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:@[]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:[[@[] mutableCopy] autorelease]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
        });
        
        describe(@"NSMutableArray", ^{
            
            beforeEach(^{
                [collection registerCellClass:[ModelCellWithNib class]
                                forModelClass:[NSMutableArray class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionHeader
                                         forModelClass:[NSMutableArray class]];
                [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                               forKind:UICollectionElementKindSectionFooter
                                         forModelClass:[NSMutableArray class]];
            });
            
            it(@"should accept NSArray for cells", ^{
                ^{
                    [collection addItem:@[]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for cells", ^{
                ^{
                    [collection addItem:[[@[] mutableCopy] autorelease]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSArray for header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:@[]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for header", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObject:[[@[] mutableCopy] autorelease]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSArray for footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:@[]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for footer", ^{
                ^{
                    [[collection supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObject:[[@[] mutableCopy] autorelease]];
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });

            
        });
    });
});

SPEC_END
