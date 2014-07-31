#import "DTCollectionViewController.h"
#import "Model.h"
#import "ModelCell.h"
#import "ModelCellWithNib.h"
#import "SupplementaryViewWithNib.h"
#import "DTMemoryStorage+UpdateWithoutAnimations.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(Mapping)

describe(@"Mapping tests", ^{
    __block DTCollectionViewController *collection;
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        [CATransaction setDisableActions:YES];
        
        collection = [DTCollectionViewController new];
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.headerReferenceSize = CGSizeMake(200, 300);
        layout.footerReferenceSize = CGSizeMake(200, 300);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        collection.collectionView = [[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)
                                                       collectionViewLayout:layout] autorelease];
        [layout release];
        collection.collectionView.dataSource = collection;
        collection.collectionView.delegate = collection;
    });
    
    afterEach(^{
        [UIView setAnimationsEnabled:YES];
    });
    
    describe(@"cell mapping", ^{
        
        it(@"should be able to register cell nib", ^{
            [collection registerCellClass:[ModelCellWithNib class] forModelClass:[Model class]];
            [collection.memoryStorage addItem:[[Model new] autorelease]];
            
            UICollectionView * collectionView = collection.collectionView;
            NSObject <UICollectionViewDataSource> * dataSource = collectionView.dataSource;
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            UICollectionViewCell * cell = [dataSource collectionView:collectionView
                                              cellForItemAtIndexPath:indexPath];
            
            cell should be_instance_of([ModelCellWithNib class]);

            ModelCellWithNib * castedCell = (ModelCellWithNib *)cell;
            
            castedCell.inittedWithFrame should_not BeTruthy();
            castedCell.awakenFromNib should BeTruthy();
        });
        
        it(@"should be able to register cell with custom nib", ^{
            [collection registerNibNamed:@"ModelCellWithNib" forCellClass:[ModelCellWithNib class]
                           forModelClass:[Model class]];
            [collection.memoryStorage addItem:[[Model new] autorelease]];
            
            UICollectionView * collectionView = collection.collectionView;
            NSObject <UICollectionViewDataSource> * dataSource = collectionView.dataSource;
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            UICollectionViewCell * cell = [dataSource collectionView:collectionView
                                              cellForItemAtIndexPath:indexPath];
            
            cell should be_instance_of([ModelCellWithNib class]);
            
            ModelCellWithNib * castedCell = (ModelCellWithNib *)cell;
            
            castedCell.inittedWithFrame should_not BeTruthy();
            castedCell.awakenFromNib should BeTruthy();
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
            [UIView setAnimationsEnabled:NO];
            [CATransaction setDisableActions:YES];
        });
        
        it(@"should be able to register supplementary header nib class", ^{
            [collection registerSupplementaryClass:[SupplementaryViewWithNib class]
                                           forKind:UICollectionElementKindSectionHeader
                                     forModelClass:[Model class]];
            
            [collection.memoryStorage updateWithoutAnimations:^{
                [collection.memoryStorage setSupplementaries:@[[[Model new] autorelease]]
                                                     forKind:UICollectionElementKindSectionHeader];
                [collection.memoryStorage addItem:[[Model new] autorelease]];
                
            }];
            
            [collection.collectionView reloadData];
            [collection.collectionView performBatchUpdates:nil completion:nil];
            
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
            
            [collection.memoryStorage updateWithoutAnimations:^{
                [collection.memoryStorage setSupplementaries:@[[[Model new] autorelease]]
                                                     forKind:UICollectionElementKindSectionFooter];
                [collection.memoryStorage addItem:[[Model new] autorelease]];
            }];
            
            [collection.collectionView reloadData];
            [collection.collectionView performBatchUpdates:nil completion:nil];
            
            id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
            UIView * view = [datasource collectionView:collection.collectionView
                     viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                           atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            SupplementaryView * header = (SupplementaryView *) view;
            [header class] should equal([SupplementaryViewWithNib class]);
            header.inittedWithFrame should_not BeTruthy();
            header.awakenFromNib should BeTruthy();
        });
        
        it(@"should be able to register supplementary header nib class with custom nib", ^{
            [collection registerNibNamed:@"SupplementaryViewWithNib"
                   forSupplementaryClass:[SupplementaryViewWithNib class]
                                 forKind:UICollectionElementKindSectionHeader
                           forModelClass:[Model class]];
            
            [collection.memoryStorage updateWithoutAnimations:^{
                [collection.memoryStorage setSupplementaries:@[[[Model new] autorelease]]
                                                     forKind:UICollectionElementKindSectionHeader];
                [collection.memoryStorage addItem:[[Model new] autorelease]];
                
            }];
            
            [collection.collectionView reloadData];
            [collection.collectionView performBatchUpdates:nil completion:nil];
            
            id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
            UIView * view = [datasource collectionView:collection.collectionView
                     viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                           atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            SupplementaryView * header = (SupplementaryView *) view;
            [header class] should equal([SupplementaryViewWithNib class]);
            header.inittedWithFrame should_not BeTruthy();
            header.awakenFromNib should BeTruthy();
        });
        
        it(@"should be able to register supplementary footer nib class with custom nib", ^{
            [collection registerNibNamed:@"SupplementaryViewWithNib"
                   forSupplementaryClass:[SupplementaryViewWithNib class]
                                 forKind:UICollectionElementKindSectionFooter
                           forModelClass:[Model class]];
            
            [collection.memoryStorage updateWithoutAnimations:^{
                [collection.memoryStorage setSupplementaries:@[[[Model new] autorelease]]
                                                     forKind:UICollectionElementKindSectionFooter];
                [collection.memoryStorage addItem:[[Model new] autorelease]];
            }];
            
            [collection.collectionView reloadData];
            [collection.collectionView performBatchUpdates:nil completion:nil];
            
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
                    [collection.memoryStorage addItem:@""];
                } should_not raise_exception;
            });
            
            it(@"should accept non-empty strings", ^{
                ^{
                    [collection.memoryStorage addItem:@"not empty"];
                } should_not raise_exception;
            });
            
            it(@"should accept mutable string", ^{
                ^{
                    NSMutableString * string = [[NSMutableString alloc] initWithString:@"first"];
                    [string appendString:@",second"];
                    [collection.memoryStorage addItem:string];
                    [string release];
                } should_not raise_exception;
            });
            
            it(@"should accept NSString header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@"foo"]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];
                    
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception; 
            });
            
            it(@"should accept NSString footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@"foo"]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

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
                    [collection.memoryStorage addItem:@""];
                } should_not raise_exception;
            });
            
            it(@"should accept non-empty strings", ^{
                ^{
                    [collection.memoryStorage addItem:@"not empty"];
                } should_not raise_exception;
            });
            
            it(@"should accept mutable string", ^{
                ^{
                    NSMutableString * string = [[NSMutableString alloc] initWithString:@"first"];
                    [string appendString:@",second"];
                    [collection.memoryStorage addItem:string];
                    [string release];
                } should_not raise_exception;
            });
            
            it(@"should accept NSString header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@"foo"]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSString footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@"foo"]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

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
                    [collection.memoryStorage addItem:@5];
                } should_not raise_exception;
            });
            
            it(@"should accept bool number for cells", ^{
                ^{
                    [collection.memoryStorage addItem:@YES];
                } should_not raise_exception;
            });
            
            it(@"should accept number for header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@5]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept number for footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@5]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];
                    
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept BOOL for header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@YES]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept bool for footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@YES]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

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
                    [collection.memoryStorage addItem:@{@1:@2}];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for cells", ^{
                ^{
                    [collection.memoryStorage addItem:[[@{@1:@2} mutableCopy] autorelease]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSDictionary for header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@{}]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSDictionary for footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@{}]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[[[@{} mutableCopy] autorelease]]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];
                    
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[[[@{} mutableCopy] autorelease]]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

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
                    [collection.memoryStorage addItem:@{@1:@2}];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for cells", ^{
                ^{
                    [collection.memoryStorage addItem:[[@{@1:@2} mutableCopy] autorelease]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSDictionary for header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@{}]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSDictionary for footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@{}]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[[[@{} mutableCopy] autorelease]]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableDictionary for footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[[[@{} mutableCopy] autorelease]]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];
                    
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
                    [collection.memoryStorage addItem:@[]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for cells", ^{
                ^{
                    [collection.memoryStorage addItem:[[@[] mutableCopy] autorelease]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSArray for header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@[]]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];
                    
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[[[@[] mutableCopy] autorelease]]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];
                    
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSArray for footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@[]]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[[[@[] mutableCopy] autorelease]]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

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
                    [collection.memoryStorage addItem:@[]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for cells", ^{
                ^{
                    [collection.memoryStorage addItem:[[@[] mutableCopy] autorelease]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSArray for header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@[]]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];

                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for header", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[[[@[] mutableCopy] autorelease]]
                                                             forKind:UICollectionElementKindSectionHeader];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];
                    
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSArray for footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[@[]]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];
             
                    id <UICollectionViewDataSource> datasource = collection.collectionView.dataSource;
                    [datasource collectionView:collection.collectionView
             viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                   atIndexPath:[NSIndexPath indexPathForItem:0
                                                                   inSection:0]];
                } should_not raise_exception;
            });
            
            it(@"should accept NSMutableArray for footer", ^{
                ^{
                    [collection.memoryStorage updateWithoutAnimations:^{
                        [collection.memoryStorage setSupplementaries:@[[[@[] mutableCopy] autorelease]]
                                                             forKind:UICollectionElementKindSectionFooter];
                        [collection.memoryStorage addItem:[[Model new] autorelease]];
                    }];
                    
                    [collection.collectionView reloadData];
                    [collection.collectionView performBatchUpdates:nil completion:nil];
                    
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
