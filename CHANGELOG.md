# Change Log
All notable changes to this project will be documented in this file.

# Next

## [11.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/11.0.0)

### Added

* Support for `UICollectionViewDelegate.collectionView(_:canPerformPrimaryActionForItemAt:)` and `UICollectionViewDelegate.collectionView(_:performPrimaryActionForItemAt:)` delegate methods on iOS 16 and tvOS 16.
* Support for `UICollectionViewDelegate.collectionView(_:contextMenuConfigurationForItemsAt:point:)`, `UICollectionViewDelegate.collectionView(_:contextMenuConfiguration:highlightPreviewForItemAt:`) and `UICollectionViewDelegate.collectionView(_:contextMenuConfiguration:dismissalPreviewForItemAt:` methods on iOS 16.
* Support for `UIHostingConfiguration` on iOS 16 / tvOS 16 / macCatalyst 16:

```swift
manager.registerHostingConfiguration(for: Post.self) { _, post, _ in
    UIHostingConfiguration {
        PostView(post: post)
    }
}
```

It's also possible to incorporate UIKit cell states by simply adding additional parameter to registration:

```swift
manager.registerHostingConfiguration(for: Post.self) { state, _, post, _ in
    UIHostingConfiguration {
        PostView(post: post, isSelected: state.isSelected)
    }
}
```

Additionally, it's possible to customize `UICollectionViewCell` being used to host SwiftUI view, for example for list cells:

```swift
manager.registerHostingConfiguration(for: Post.self, cell: UICollectionViewListCell.self) { _, post, _ in
    UIHostingConfiguration {
        PostView(post: post)
    }
}
```

* Support for events, wrapping `UICollectionViewDataSourcePrefetching` protocol. 

```swift
manager.register(PostCell.self) { mapping in
    mapping.prefetch { model, indexPath in }
    mapping.cancelPrefetch { model, indexPath in }
}
```

> Please note, that while datasource methods are called once per array of indexPaths, events for models will be called individually, so single model (and indexPath) is passed to each event. Theoretically, this should make prefetching and cancellation easier, since you no longer need to walk through array and find all data models, you can operate on a single data model at a time.

### Deprecated

* Cell / View events, registered with `DTCollectionViewManager` are soft-deprecated. Please use events in mapping instead:

Deprecated:
```swift
    manager.register(PostCell.self)
    manager.didSelect(PostCell.self) { postCell, post, indexPath in }
```
Recommended:
```swift
    manager.register(PostCell.self) { mapping in
        mapping.didSelect { postCell, post, indexPath in }
    }
```
> While previously main benefits for second syntax were mostly syntactic, now with support for SwiftUI it will be hard to actually specialize hosting cells (and might be impossible when iOS 16 hosting configuration is supported), so only second syntax will work for all kinds of cells, and first syntax can only work for non-SwiftUI cells.
> New delegate methods for UICollectionView (starting with iOS 16 / tvO 16 SDK) will be added only as extension to mapping protocols, not DTCollectionViewManager itself.

## [11.0.0-beta.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/11.0.0-beta.1)

### **Introducing support for SwiftUI!**

Registering SwiftUI views as content for collection view cells:

```swift
manager.registerHostingCell(for: Post.self) { model, indexPath in
    PostSwiftUIView(model: model)
}
```

This method is supported on iOS 13+ / tvOS 13+ / macCatalyst 13+. 

> Please note, that this integration is not supported by Apple, therefore it comes with several workarounds, read more about those in [SwiftUI support document](Documentation/SwiftUI.md)

### Added

* `HostingCellViewModelMapping` - `CellViewModelMapping` subclass to register mappings fro SwiftUI views.
* `HostingCollectionViewCell` - `UICollectionViewCell` subclass , implementing container for SwiftUI view embedded into it.
* `HostingCollectionViewCellConfiguration` - configuration for SwiftUI views hosting inside `HostingCollectionViewCell`.

### Changed

* Event reactions are now defined in protocol extension instead of extending former `ViewModelMapping` protocol, thus allowing to call those methods not only for UIKit mappings, but SwiftUI-hosted cells as well.

### Breaking

* `ViewModelMapping` class and it's protocol have been split into multiple classes and protocols for better subclassability (for example `CellViewModelMapping` / `CollectionViewCellModelMapping`). Please note, that while technically this is breaking, it's very unlikely to break anything in code, since this type is only present in mapping closures, and public interfaces did not change at all.

## [10.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/10.0.0)

### Added

* Wrappers for `collectionView:selectionFollowsFocusForItemAtIndexPath:` delegate method.
* Wrappers for iOS 15 `UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveOfItemFromOriginalIndexPath:atCurrentIndexPath:toProposedIndexPath:)` delegate method.

### Removed

* Wrappers for `collectionView:willCommitMenuWithAnimator` delegate method, that was only briefly available in Xcode 12, and was removed by Apple in one of Xcode 12 releases.

### Changed

* To align version numbers between `DTModelStorage`, `DTTableViewManager` and `DTCollectionViewManager`, `DTCollectionViewManager` will not have 9.x release, instead it's being released as 10.x.

### Deprecated

* `targetIndexPathForMovingItem` deprecated on iOS / tvOS 15 and higher, because delegate method `collectionView:targetIndexPathForMoveFromItemAt:toProposedIndexPath:` was deprecated in favor of newer method.

## [9.0.0-beta.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/9.0.0-beta.1)

### Fixed

* Diffable datasources exceptions in Xcode 13 / iOS 15 with some internal restructuring.

### Removed

* Deprecated support for `UICollectionViewDiffableDataSourceReference`

## [8.2.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/8.2.0)

### Changed

* `UICollectionViewDatasource`.`indexTitles(for:)` and `UICollectionViewDatasource`.`collectionView(_: indexPathForIndexTitle:at:)` methods and events now require iOS 14 (and seem to be working only on iOS 14) as per SDK changes in Xcode 12.5.

### Fixed

* Xcode 12.5 / Swift 5.4 warnings
* Cell and supplementary view anomaly verification now correctly checks if corresponding subclasses respond to `init(frame:)` initializer.

## [8.1.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/8.1.0)

This release fixes a critical issue with cell and supplementary reuse on iOS 14 / tvOS 14. If you are using 8.x release, it's highly recommended to upgrade to this release.

### Changed

* `UICollectionView.CellRegistration` and `UICollectionView.SupplementaryRegistration` on iOS 14 / tvOS 14 are now created once per mapping, thus properly allowing cell and supplementary reuse.

### Deprecated

* `DTCollectionViewManagerAnomaly.differentCellReuseIdentifier`. If you are using cells from code or from xib, please use empty reuseIdentifier, because on iOS 14 / tvOS 14 reuseIdentifiers are being set by `UICollectionView.CellRegistration` object. If you are using storyboards, set reuseIdentifier of the cell to cell subclass name.

## [8.0.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/8.0.1)

### Fixed

* Typo, that caused anomalies to trigger when using events for UICollectionViewLayout(thanks, @RenGate).

## [8.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/8.0.0)

### Added

* Registering events for `UICollectionViewDelegateFlowLayout` protocol now triggers an anomaly, if different layout class is used (for example `UICollectionViewCompositionalLayout`)

## [8.0.0-beta.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/8.0.0-beta.1)

**This is a major release with some breaking changes, please read [DTCollectionViewManager 8.0 Migration Guide](Documentation/Migration%20Guides/8.0%20Migration%20Guide.md)**

### New

* Cell and supplementary view events are now available inside mapping closure directly, for example:

```swift
// Previous releases
manager.register(PostCell.self)
manager.didSelect(PostCell.self) { cell, model, indexPath in
    // React to selection
}

// New
manager.register(PostCell.self) { mapping in
    mapping.didSelect { cell, model, indexPath in

    }
}
```
Those events are now tied to `ViewModelMapping` instance, which means, that events, registered this way, will only trigger, if mapping condition of current mapping applies. For example:

```swift
manager.register(PostCell.self) { mapping in
    mapping.condition = .section(0)
    mapping.didSelect { cell, model, indexPath in  
        // This closure will only get called, when user selects cell in the first section
    }
}
manager.register(PostCell.self) { mapping in
    mapping.condition = .section(1)
    mapping.didSelect { cell, model, indexPath in  
        // This closure will only get called, when user selects cell in the second section
    }
}
```

* It's now possible to register collection view cells, that don't conform to `DTModelTransfer` protocol:

```swift
manager.register(UICollectionViewCell.self, String.self) { cell, indexPath, model in
    // configure cell with model which is of type String when passed into configuration closure.
}
```

This is particularly useful on iOS / tvOS 14 and higher, where you can configure `UICollectionViewListCell` without needing to subclass it.
Cells, registered in this way, can safely coexist with cells, that conform to `DTModelTransfer` protocol. Conditional mappings are also supported (multiple trailing closures syntax available in Swift 5.3):

```swift
manager.register(UICollectionViewCell.self, for: String.self) {
    $0.condition = .section(0)
} handler { cell, indexPath, model in
  // configure cell with model which is of type String when passed into configuration closure.
}
```

* Added event reaction for `UICollectionViewDelegate.collectionView(_:canEditItemAt:)` delegate method.
* Added event reactions for tvOS 13 `TVCollectionViewDelegateFullScreenLayout` protocol from `TVUIKit` framework.
* New readme and [in-depth documentation](Documentation), split into several sections for developer convenience.

### Changed

* On iOS/tvOS 14 and higher, cell and supplementary views now use `UICollectionView.dequeueConfiguredReusableCell` and `UICollectionView.dequeueConfiguredReusableSupplementary` to be dequeued.
* `DTModelTransfer` `update(with:)` method for such cells and supplementary views is called immediately after `dequeueConfiguredReusableCell` \ `dequeueConfiguredReusableSupplementary` return.
* Generic placeholders for cell/model/view methods have been improved for better readability.

### Breaking

This release requires Swift 5.3. Minimum iOS / tvOS deployment targets are unchanged (iOS 11, tvOS 11).

Some context: this release heavily relies on where clauses on contextually generic declarations, that are only available in Swift 5.3 - [SE-0267](https://github.com/apple/swift-evolution/blob/master/proposals/0267-where-on-contextually-generic.md).

* Cells, headers and footers created in storyboard now need to be explicitly configured in view mapping:

```swift
register(StoryboardCell.self) { mapping in
    mapping.cellRegisteredByStoryboard = true
}

registerHeader(StoryboardHeader.self) { mapping in
    mapping.supplementaryRegisteredByStoryboard = true
}
```

* All non-deprecated registration methods now have an additional `handler` closure, that allows to configure cells/headers/footers/supplementary views that are dequeued from UICollectionView. This is a direct replacement for `configure(_:_:`, `configureHeader(_:_:)`, `configureFooter(_:_:)` and `configureSupplementary(_:ofKind:_:`, that are all now deprecated.
* On iOS / tvOS 14 / Xcode 12 and higher handler closure, that is passed to registration methods, is used to call new `dequeueConfiguredReusableCell(using:for:item:)` and `dequeueConfiguredReusableSupplementary(using:for:)` methods on UICollectionView. Please note, that handler closure is called before `DTModelTransfer.update(with:)` method because of how new UICollectionView dequeue API works.
* `ViewModelMapping` is now a generic class, that captures view and model information(ViewModelMapping<T,U>).
* `CollectionViewUpdater.batchUpdatesInProgress` property was removed.

### Deprecated

* Several cell/header/footer/supplementary view registration methods have been deprecated to unify registration logic. Please use `register(_:mapping:handler:)`, `registerHeader(_:mapping:handler:)`, `registerFooter(_:mapping:handler:)` and `registerSupplementary(_:forKind:mapping:handler:)` as a replacements for all of those methods. For more information on those changes, please read [migration guide](Documentation/Migration%20Guides/8.0%20Migration%20Guide.md)
* `DTCollectionViewManager.configureEvents(for:_:)`, it's functionality has become unnecessary since mapping closure of cell/supplementary registration now captures both cell and model type information for such events.
* `DTCollectionViewManager.configureDiffableDataSource(modelProvider:)` for non-hashable data models. Please use configureDiffableDataSource method for models, that are Hashable. From Apple's documentation: `If you’re working in a Swift codebase, always use UICollectionViewDiffableDataSource instead`.

### Fixed

* Supplementary views now correctly use `ViewModelMapping.reuseIdentifier` instead of falling back to name of the view class.
* Several event API's have been improved to allow returning nil for methods, that accept nil as a valid value:
`contextMenuConfiguration`, `previewForHighlightingContextMenu`, `previewForDismissingContextMenu`

## [7.2.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/7.2.0)

### Changed

* Deployment targets - iOS 11 / tvOS 11.
* Minimum Swift version required: 5.0
* Added support for DTModelStorage/Realm with Realm 5

Please note, that this framework version source is identical to previous version, which supports iOS 8 / tvOS 9 / Swift 4.2 and higher.

## [7.1.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/7.1.0)

### Changed

* It's not longer necessary to import DTModelStorage framework to use it's API's. `import DTCollectionViewManager` now implicitly exports `DTModelStorage` as well.

## [7.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/7.0.0)

* `willCommitMenuWithAnimator` method has been made unavailable for Xcode 11.2, because `UICollectionViewDelegate` method it used has been removed from UIKit on Xcode 11.2.

## [7.0.0-beta.2](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/7.0.0-beta.2)

* Added support for Xcode versions, that are older than Xcode 11.

## [7.0.0-beta.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/7.0.0-beta.1)

**This is a major release with some breaking changes, please read [DTCollectionViewManager 7.0 Migration Guide](Documentation/Migration%20Guides/7.0%20Migration%20Guide.md)**

### Changed

* DTCollectionViewManager now requires to be built with Swift 4.2 and later.
* Anomaly event verification now allows subclasses to prevent false-positives.
* `animateChangesOffScreen` property on `CollectionViewUpdater` that allows to turn off animated updates for `UICollectionView` when it is not on screen.

### Added

* `configureDiffableDataSource(modelProvider:)` method to enable `UICollectionViewDiffableDataSource` with `DTCollectionViewManager`.
* `DTCollectionViewManager.supplementaryStorage` getter, that conditionally casts current storage to `SupplementaryStorage` protocol.
* Ability to customize bundle, from which xib files are loaded from by setting `bundle` property on `ViewModelMapping` in `mappingBlock`. As before, `bundle` defaults to `Bundle(for: ViewClass.self)`.

New method wrappers for iOS 13 API

* `shouldBeginMultipleSelectionInteraction`
* `didBeginMultipleSelectionInteraction`
* `didEndMultipleSelectionInteraction`
* `contextMenuConfiguration(for:)`
* `previewForHighlightingContextMenu`
* `previewForDismissingContextMenu`
* `willCommitMenuWithAnimator`

### Removed

* Usage of previously deprecated and now removed from `DTModelStorage` `ViewModelMappingCustomizing` protocol.

### Breaking

DTModelStorage header, footer and supplementary model handling has been largely restructured to be a single closure-based API. Read more about changes in [DTModelStorage changelog](https://github.com/DenTelezhkin/DTModelStorage/blob/master/CHANGELOG.md). As a result of those changes, several breaking changes in DTCollectionViewManager include:

* `SectionModel` extension with `collectionHeaderModel` and `collectionFooterModel` properties has been removed.
* Because headers/footers are now a closure based API, `setSectionHeaderModels` and `setSectionFooterModels` do not create sections by default, and do not call collectionView.reloadData.

Other breaking changes:

* `collectionViewUpdater` will contain nil if `DTCollectionViewManager` is configured to work with `UICollectionViewDiffableDataSource`.
* `DTCollectionViewNonOptionalManageable` protocol was removed and replaced by `collectionView` property on `DTCollectionViewManageable` protocol. One of `collectionView`/`optionalCollectionView` properties must be implemented by `DTCollectionViewManageable` instance to work with `DTCollectionViewManager`.
* `collectionView` property in `DTCollectionViewManageable` protocol is now `ImplicitlyUnwrappedOptional` instead of `Optional`. This change is done to unify API with `UICollectionViewController` change and `DTTableViewManager` API for consistency.

**WARNING**  Because of default implementations for new property this will not show as a compile error, instead crashing in runtime. Please make sure to update all definitions of

`var collectionView: UICollectionView?`

to

`var collectionView: UICollectionView!`.

If you need optional collection view, use `optionalCollectionView` property instead.

### Deprecated

Following methods have been deprecated due to their delegate methods being deprecated in iOS 13:

* `shouldShowMenuForItemAt`
* `canPerformAction`
* `performAction`

## [6.6.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.6.0)

* Added support for Swift Package Manager in Xcode 11

## [6.5.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.5.0)

### Added

* Convenience constructor for `DTCollectionViewManager` object: `init(storage:)` that allows to create it's instance without initializing `MemoryStorage`.
* Static variable `defaultStorage` on `DTCollectionViewManager` that allows to configure which `Storage` class is used by default.
* [Documentation](https://dentelezhkin.github.io/DTCollectionViewManager)
* Support for Xcode 10.2 and Swift 5

### Removed

* Support for Xcode 9 and Swift 3

## [6.4.2](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.4.2)

* `move(:_,:_)` method was deprecated and no longer works due to a logic bug, that can prevent this method from being called if sourceIndexPath is off screen when this event was called by `UICollectionView`. Please use new method `moveItemAtTo(:_)` to subscribe to move events in the datasource.

## [6.4.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.4.1)

* Fix infinite recursion bug with UICollectionView.canFocusItemAt(:) method(thanks, @skydivedan!)

## [6.4.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.4.0)

* Support for Xcode 10 and Swift 4.2

## [6.3.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.3.0)

### Added

* Anomaly-detecting and reporting system for `DTCollectionViewManager`. Read more about it in [Anomaly Handler Readme section](https://github.com/DenTelezhkin/DTCollectionViewManager#anomaly-handler). Anomaly handler system **requires Swift 4.1 and higher**.
* Support for Swift 4.2 in Xcode 10 (beta 1).

### Changed

* Calling `startManaging(withDelegate:_)` method is no longer required.

### Breaking

* `viewFactoryErrorHandler` property on `DTCollectionViewManager` was removed, all supported errors and warnings are now a part of anomaly reporting system

## [6.1.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.1.1)

## [6.1.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.1.0)

## [6.1.0-beta.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.1.0-beta.1)

* Implemented new system for deferring datasource updates until `performBatchUpdates` block. This system is intended to fight crash, that might happen when `performBatchUpdates` method is called after `UICollectionView.reloadData` method(for example after calling `memoryStorage.setItems`, and then immediately `memoryStorage.addItems`). This issue is detailed in https://github.com/DenTelezhkin/DTCollectionViewManager/issues/27 and https://github.com/DenTelezhkin/DTCollectionViewManager/issues/23. This crash can also happen, if iOS 11 API `UITableView.performBatchUpdates` is used. This system is turned on by default. If, for some reason, you want to disable it and have old behavior, call:

```swift
manager.memoryStorage.defersDatasourceUpdates = false
```

Please note, though, that new default behavior is recommended, because it is more stable and works the same on both UITableView and UICollectionView.

* `collectionViewUpdater` property on `DTCollectionViewManager` is now of `CollectionViewUpdater` type instead of opaque `StorageUpdating` type. This should ease use of this object and prevent unneccessary type casts.

## [6.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.0.0)

* Updated for Xcode 9.1 / Swift 4.0.2

## [6.0.0-beta.3](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.0.0-beta.3)

* Makes `DTCollectionViewManager` property weak instead of unowned to prevent iOS 10-specific memory issues/crashes.

## [6.0.0-beta.2](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.0.0-beta.2)

* Build with Xcode 9.0 final release.
* Fixed partial-availability warnings.

## [6.0.0-beta.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/6.0.0-beta.1)

**This is a major release with some breaking changes, please read [DTTableViewManager 6.0 Migration Guide](https://github.com/DenTelezhkin/DTTableViewManager/blob/master/Documentation/DTTableViewManager%206.0%20Migration%20Guide.md)**

* Added `updateVisibleCells(_:) method`, that allows updating cell data for visible cells with callback on each cell. This is more efficient than calling `reloadData` when number of elements in `UICollectionView` does not change, and only contents of items change.
* Implement `configureEvents(for:_:)` method, that allows batching in several cell events to avoid using T.ModelType for events, that do not have cell created.
* Added `DTCollectionViewDropPlaceholderContext` wrapper with convenience support for UICollectionView placeholders.
* Implemented `UICollectionViewDragDelegate` and `UICollectionViewDropDelegate` events.
* Added 10 more `UICollectionViewDelegate` and `UICollectionViewDelegateFlowLayout` events.
* Added missing events for `UICollectionViewDatasource` protocol: `collectionView:moveItemAt:to:`, `indexTitlesFor:`, `collectionView:indexPathForIndexTitle:at:`
* Implemented conditional mappings
* `UICollectionViewDelegate` and `UICollectionViewDatasource` implementations have been refactored from `DTCollectionViewManager` to `DTCollectionViewDelegate` and `DTCollectionViewDataSource` classes.
* Added `DTCollectionViewNonOptionalManageable` protocol, that can be used with non-optional `UICollectionView` properties on your managed instance.

## [5.3.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/5.3.1)

* Initial support for Swift 3.2 (Xcode 9 beta-1).
* Fixed `registerNiblessHeader` and `registerNiblessFooter` to properly call nibless supplementary methods.

## [5.3.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/5.3.0)

* Use new events system from `DTModelStorage`, that allows events to be properly called for cells, that are created using `ViewModelMappingCustomizing` protocol.

## [5.2.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/5.2.0)

* Setting `CollectionViewUpdater` instance to `collectionViewUpdater` property on `DTCollectionViewManager` now triggers `didUpdateContent` closure on `CollectionViewUpdater`.

## [5.1.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/5.1.0)

Dependency changelog -> [DTModelStorage 4.0.0 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

* `CollectionViewUpdater` has been rewritten to use new `StorageUpdate` properties that track changes in order of their occurence.
* `CollectionViewUpdater` `reloadItemClosure` and `DTCollectionViewManager` `updateCellClosure` now accept indexPath and model instead of just indexPath. This is done because update may happen after insertions and deletions and object that needs to be updated may exist on different indexPath.

## [5.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/5.0.0)

No changes

## [5.0.0-beta.2](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/5.0.0-beta.2)

* Enables `RealmStorage` from `DTModelStorage` dependency.

## [5.0.0-beta.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/5.0.0-beta.1)

This is a major release, written in Swift 3. Read [Migration guide](https://github.com/DenTelezhkin/DTCollectionViewManager/blob/e0be426c06e92d565e0ad94cc04d54dda0532871/Guides/DTCollectionViewManager%205%20migration%20guide.md) with descriptions of all features and changes.

Dependency changelog -> [DTModelStorage 3.0.0 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

### Added

* New events system that covers almost all available `UICollectionViewDelegate`, `UICollectionViewDataSource` and `UICollectionViewDelegateFlowLayout` delegate methods.
* New class - `CollectionViewUpdater`, that is calling all animation methods for `UICollectionView` when required by underlying storage.
* `updateCellClosure` method on `DTCollectionViewManager`, that manually updates visible cell instead of calling `collectionView.reloadItemsAt(_:)` method.
* `coreDataUpdater` property on `DTCollectionViewManager`, that creates `CollectionViewUpdater` object, that follows Apple's guide for updating `UICollectionView` from `NSFetchedResultsControllerDelegate` events.
* `isManagingCollectionView` property on `DTCollectionViewManager`.
* `unregisterCellClass(_:)`, `unregisterHeaderClass(_:)`, `unregisterFooterClass(_:)`, `unregisterSupplementaryClass(_:forKind:)` methods to unregister mappings from `DTCollectionViewManager` and `UICollectionView`

### Changed

* Swift 3 API Design guidelines have been applied to all public API.
* Event system is migrated to new `EventReaction` class from `DTModelStorage`
* Now all view registration methods use `NSBundle(forClass:)` constructor, instead of falling back on `DTCollectionViewManager` `viewBundle` property. This allows having cells from separate bundles or frameworks to be used with single `DTCollectionViewManager` instance.

### Removals

* `viewBundle` property on `DTCollectionViewManager`
* `itemForVisibleCell`, `itemForCellClass:atIndexPath:`, `itemForHeaderClass:atSectionIndex:`, `itemForFooterClass:atSectionIndex:` were removed - they were not particularly useful and can be replaced with much shorter Swift conditional typecasts.
* All events methods with method pointer semantics. Please use block based methods instead.
* `registerCellClass:whenSelected` method, that was tightly coupling something that did not need coupling.

## [4.8.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.8.0)

### Changed

* Now all view registration methods use `NSBundle(forClass:)` constructor, instead of falling back on `DTCollectionViewManager` `viewBundle` property. This allows having cells from separate bundles or frameworks to be used with single `DTCollectionViewManager` instance.

### Deprecations

* `viewBundle` property on `DTCollectionViewManager`

## [4.7.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.7.0)

Dependency changelog -> [DTModelStorage 2.6.0 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

## [4.6.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.6.0)

Dependency changelog -> [DTModelStorage 2.5 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

### Breaking

* Update to Swift 2.2. This release is not backwards compatible with Swift 2.1.

### Changed

* Require Only-App-Extension-Safe API is set to YES in framework targets.

## [4.5.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.5.0)

Dependency changelog -> [DTModelStorage 2.4 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

## Added

* Support for Realm database storage - using `RealmStorage` class.
* `batchUpdatesInProgress` property on `DTCollectionViewManager` that indicates if batch updates are finished or not.  

## Changed

* UIReactions now properly unwrap data models, even for cases when model contains double optional value.

## [4.4.2](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.4.2)

## Fixed

* Fixed a rare crash, that could happen when new items are being added to UICollectionView prior to UICollectionView calling any delegate methods

## [4.4.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.4.1)

## Fixed

* Issue with Swift 2.1.1 (XCode 7.2) where storage.delegate was not set during initialization

## [4.4.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.4.0)

Dependency changelog -> [DTModelStorage 2.3 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

This release aims to improve mapping system and error reporting.

## Added

* [New mapping system](https://github.com/DenTelezhkin/DTCollectionViewManager#data-models) with support for protocols and subclasses
* Mappings can now be [customized](https://github.com/DenTelezhkin/DTCollectionViewManager#customizing-mapping-resolution) using `DTViewModelMappingCustomizable` protocol.
* [Custom error handler](https://github.com/DenTelezhkin/DTCollectionViewManager#error-reporting) for `DTCollectionViewFactoryError` errors.

## Changed

* preconditionFailures have been replaced with `DTCollectionViewFactoryError` ErrorType
* Internal `CollectionViewReaction` class have been replaced by `UIReaction` class from DTModelStorage.

## [4.3.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.3.0)

Dependency changelog -> [DTModelStorage 2.2 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

## Changed

* Added support for AppleTV platform (tvOS)

## Fixed

* Footer and supplementary configuration closures and method pointers

## Changed

* Improved failure cases for situations where cell or supplementary mappings were not found

## [4.2.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.2.1)

### Updated

* Improved stability by treating UICollectionView as optional

## [4.2.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.2.0)

Dependency changelog -> [DTModelStorage 2.1 and higher](https://github.com/DenTelezhkin/DTModelStorage/releases)

This release aims to improve storage updates and UI animation with UICollectionView. To make this happen, `DTModelStorage` classes were rewritten and rearchitectured, allowing finally to remove truly [historic workaround](https://github.com/DenTelezhkin/DTCollectionViewManager/commit/19ae8337b1f6442d1bd588b482d24395e99a2259#diff-7a0b0d0332a60e359c3b8e67a4034f09L674). This code was initially written to fix first item insertion and deletion of items in UICollectionView. Somewhere between iOS 6 and iOS 8 Apple has fixed bugs, that caused this behaviour to happen. This is not documented, and was not mentioned anywhere, and i was very lucky to find this out by accident. So finally, I was able to remove these workarounds(which by the way are almost [two years old](https://github.com/DenTelezhkin/DTCollectionViewManager/commit/0a4a33ba69a8a9752e84ffbf8f2d5c84ed8cd2aa)), and UICollectionView UI updates code is as clean as UITableView UI updates code.

There are some backwards-incompatible changes in this release, however Xcode quick-fix tips should guide you through what needs to be changed.

## Added

 * `registerNiblessCellClass` and `registerNiblessSupplementaryClass` methods to  support creating cells and supplementary views from code

## Bugfixes

* Fixed `cellConfiguration` method, that was working incorrectly
* Fixed retain cycles in event blocks

## [4.1.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.1.0)

## Features

New events registration system with method pointers, that automatically breaks retain cycles.

For example, cell selection:

```swift
manager.cellSelection(PostsViewController.selectedCell)

func selectedCell(cell: PostCell, post: Post, indexPath: NSIndexPath) {
    // Do something, push controller probably?
}
```

Alternatively, you can use dynamicType to register method pointer:

```swift
manager.cellSelection(self.dynamicType.selectedCell)
```

Other available events:
* cellConfiguration
* headerConfiguration
* footerConfiguration
* supplementaryConfiguration

## Breaking changes

`beforeContentUpdate` and `afterContentUpdate` closures were replaced with `DTCollectionViewContentUpdatable` protocol, that can be adopted by your `DTCollectionViewManageable` class, for example:

```swift
extension PostsViewController: DTCollectionViewContentUpdatable {
    func afterContentUpdate() {
        // Do something
    }
}
```

## [4.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/4.0.0)

4.0 is a next major release of `DTCollectionViewManager`. It was rewritten from scratch in Swift 2 and is not backwards-compatible with previous releases.

### Features

* Improved `ModelTransfer` protocol with associated `ModelType`
* `DTCollectionViewManager` is now a separate object
* New events system, that allows reacting to cell selection, cell/header/footer configuration and content updates
* Added support for `UICollectionViewController`, and any other object, that has `UICollectionView`
* New storage object generic-type getters
* Support for Swift types - classes, structs, enums, tuples.


## [3.2.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/3.2.0)

### Bugfixes

* Fixed an issue, where storageDidPerformUpdate method could be called without any updates.

## [3.1.1](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/3.1.1)

* Added support for installation using [Carthage](https://github.com/Carthage/Carthage) :beers:

## [3.1.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/3.1.0)

## Changes

* Added nullability annotations for XCode 6.3 and Swift 1.2

## [3.0.5](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/3.0.5)

## Bugfixes

Fixed issue, that could lead to wrong collection items being removed, when using memory storage  removeItemsAtIndexPaths: method.

## [3.0.2](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/3.0.2)

## Features

Added support for installation as a framework via CocoaPods - requires iOS 8 and higher deployment target.

## [3.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/3.0.0)

3.0 is a next major release of DTCollectionViewManager. Read all about changes in detail on a [wiki page](https://github.com/DenTelezhkin/DTCollectionViewManager/wiki/DTCollectionViewManager-3.0.-What's-new%3F).

### Features
* Full Swift support, including swift model classes
* Added convenience method to update section items
* Added `DTCollectionViewControllerEvents` protocol, that allows developer to react to changes in datasource
* Added several convenience method for UICollectionViewFlowLayout. The API for supplementary header and footer registration now matches the API of DTTableViewManager.
* Added `collectionHeaderModel` and `collectionFooterModel` accessors for `DTSectionModel`.

### Breaking changes

* `DTStorage` protocol was renamed to `DTStorageProtocol`.

## [2.7.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/2.7.0)

This is a release, that is targeted at improving code readability, and reducing number of classes and protocols inside DTCollectionViewManager architecture.

### Breaking changes

* `DTCollectionViewMemoryStorage` class was removed. It's methods were transferred to `DTMemoryStorage+DTCollectionViewManagerAdditions` category.
* `DTCollectionViewStorageUpdating` protocol was removed. It's methods were moved to `DTCollectionViewController`.

### Features

* When using `DTCoreDataStorage`, section titles are displayed as headers by default(UICollectionElementKindSectionHeader), if NSFetchedController was created with sectionNameKeyPath property.

## [2.6.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/2.6.0)

## Features

Add ability to use custom xibs for collection view cells and supplementary views.

## [2.5.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/2.5.0)

### Changes

Preliminary support for Swift.

If you use cells or supplementary views inside storyboards from Swift, implement optional reuseIdentifier method to return real Swift class name instead of the mangled one. This name should also be set as reuseIdentifier in storyboard.

## [2.4.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/2.4.0)

### Breaking changes

Reuse identifier now needs to be identical to cell, header or footer class names. For example, UserTableCell should now have "UserTableCell" reuse identifier.

## [2.3.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/2.3.0)

### Deprecations

Removed `DTModelSearching` protocol, please use `DTMemoryStorage` `setSearchingBlock:forModelClass:` method instead.

## [2.2.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/2.2.0)

* `DTModelSearching` protocol is deprecated and is replaced by memoryStorage method setSearchingBlock:forModelClass:
* UICollectionViewDatasource and UICollectionViewDelegate properties for UICollectionView are now filled automatically.
* Added more assertions, programmer errors should be more easily captured.

## [2.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/2.0.0)

* DTModelTransfer and DTModelSearching protocols are now moved to DTModelStorage repo.
* Implemented searching in UICollectionView

## [2.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/2.0.0)

- Added support for custom storage classes
- Current storage classes moved to separate repo(DTModelStorage)
- Complete rewrite of internal architecture

## [1.1.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/1.1.0)

### Features

* Added support for storyboard cell, header and footer prototyping
* Dropped support for creating cells, headers and footers from code

## [1.0.0](https://github.com/DenTelezhkin/DTCollectionViewManager/releases/tag/1.0.0)

First release of DTCollectionViewManager, woohoo!

#### Features
* Clean mapping system
* Easy API for collection models manipulation
* Foundation types support
* Full iOS 7 support!
