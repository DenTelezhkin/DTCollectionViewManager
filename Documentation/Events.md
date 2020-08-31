## Reacting to events

`DTCollectionViewManager` supports registering closures instead of delegate methods for 6 delegate protocols:

* `UICollectionViewDelegate`
* `UICollectionViewDataSource`(partially)
* `UICollectionViewDelegateFlowLayout`
* `UICollectionViewDragDelegate`
* `UICollectionViewDropDelegate`
* `TVCollectionViewDelegateFullScreenLayout`

With those closures big improvement over delegate methods is that closures are actually strongly typed:

```swift
manager.register(PostCell.self) { mapping in
  mapping.didSelect { cell, model, indexPath in
    // cell is of type PostCell
    // model is of type Post
  }
}
```

### Naming

With such huge amount of delegate methods it felt important to not invent new glossary of methods over existing delegate methods. Therefore, all event methods closely follow naming of delegate methods they replace, for example:

```swift
// func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)

mapping.willDisplay { cell, model, indexPath in }

// func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool

mapping.shouldSelect { cell, model, indexPath in }
```

### Different kinds of event closures

Whenever cell or reusable view delegate method is referring to can be provided, it will be, and closure accepts three arguments: `(View, Model, IndexPath) -> ReturnType`. However, for some delegate methods cell or view is not created yet. Such delegate methods are called with signature (Model, IndexPath) -> ReturnType. For example:

```swift
// `UICollectionViewDelegateFlowLayout.collectionView(_:sizeForItemAt:)`

mapping.sizeForCell { model, indexPath in
  return CGSize(height: 44, width: 44)
}
```

You can also register event closures on `DTCollectionViewManager` instance directly, but in this case you need to provide Cell/View type again:

```swift
  manager.register(PostCell.self)
  manager.didSelect(PostCell.self) { cell, model, indexPath in }
```

> Keep in mind, that in order for this to work, cell needs to be registered prior to registering event closures, because they attach to specific mapping instance(s).

This may be beneficial for example if you show same type of cell in different section with different appearances, but selection needs to work the same way. Registering event closure through `DTCollectionViewManager` attaches this event to all compatible mappings.

If delegate method is unrelated to cells or views, it is available on `DTCollectionViewManager` instance directly:

```swift
// `UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:)`
manager.minimumLineSpacingForSectionAtIndex { layout, sectionIndex in
  return 10
}
```

### What about performance?

With `DTCollectionViewManager` implementing ALL delegate methods, you may wonder about perfomance of all of this. Also you might be concerned, that there are some methods that you don't want to be implemented because they have perfomance implications. Great example of this is `func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)` method. When used for collections with large amounts of data, it may severely impact performance if implemented. It's much better to use estimated sizes instead.

Well, I'm happy to report that performance is absolutely not an issue with `DTCollectionViewManager`. If you don't register closure for a delegate method, `UICollectionView` will think that this delegate method is not implemented and will never call it.

Wait, how is that possible? It's actually pretty simple: `DTCollectionViewManager` uses dynamic method dispatch, and specifically `responds(to selector:)` method. If no event closures are registered, `DTCollectionViewManager` simply answers that this delegate method is not implemented, and `UICollectionView` will never call the implementation.

This means, that even though all delegate methods are implemented, for `UICollectionView` implemented methods - are methods you register closures with, which is exactly what you want.

### Can I still use delegate methods?

Absolutely. Simply declare protocol conformance and implement method in your view controller:

```swift
class PostsViewController: UIViewController, DTCollectionViewManageable, UICollectionViewDelegate {
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.register(PostCell.self)
    manager.memoryStorage.setItems(posts)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // React to cell selection
  }
}
```

If your controller implements delegate method, `DTCollectionViewManager` detects it and attempts to redirect delegate method to you. It's important to understand priorities on which this is made, generally following happens:

* Try to execute event, if cell and model type satisfy requirements
* Try to call delegate or datasource method on `DTCollectionViewManageable` instance
* If two previous scenarios fail, fallback to whatever default `UICollectionView` has for this delegate or datasource method

### Limitations

While it's possible to register multiple closures for a single event, only first closure will be called once event is fired. This means that if the same event has two closures for the same view/model type, last one will be ignored. You can still register multiple event handlers for a single event and different view/model types.

`DTCollectionViewManager` considers most of datasource methods to be handled by provided `Storage`, and therefore does not provide closure replacement for those. Some of the methods are available though, such as for moving cells, and prodiving index titles.
