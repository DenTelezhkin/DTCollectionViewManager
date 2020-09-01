# Registering views

`DTCollectionViewManager` supports registering reusable views designed in code, xib file, or storyboard. It also supports registering relationship between view and it's data model through `ModelTransfer` protocol and without it.

While [Mapping document](Mapping.md) focuses on relationship between view and it's model, and [Events document](Events.md) follows on how to attach delegate methods to those mappings, this document instead focuses on registration aspect itself, and what is possible within `DTCollectionViewManager` architecture.

## Registration

In general, registering any reusable view with `DTCollectionViewManager` looks like:

```swift
manager.register(View.self) { mapping in

} handler: { view, model, indexPath in

}
```

In case of `ModelTransfer`, both `mapping` and `handler` closures are optional. If `ModelTransfer` protocol is not used, `handler` closure is required, and registration looks like:

```swift
manager.register(View.self, for: Model.self) { mapping in

} handler: { view, model, indexPath in

}
```

When any of registration methods is called, `DTCollectionViewManager` does several things:

1. Create ViewModelMapping object, and immediately run `mapping` closure on it, to give you a chance to customize any values you need. Those may include custom xib name, custom reuse identifier and others.
2. Check whether xib-file with specified name(defaults to name of the View class) exists.
3. Register view(cell/supplementary view) with UICollectionView either using nib registration or registration from code.

## Dequeue

When it's time to dequeue registered view(which is determined by model type and mapping conditions, which you can read about in [Mapping](Mapping.md) document), several things happen:

1. View is dequeued from code/xib/storyboard.
2. Handler closure is called with view, model and indexPath.
3. If `View` conforms to `ModelTransfer` protocol, `update(with:)` method is called.

On iOS 14 / tvOS 14 / macCatalyst 14.0, `UICollectionView.CellRegistration` is used to dequeue cell/supplementary view from `UICollectionView`.

## Code

Registering cells to dequeue them from code:

```swift
manager.register(CollectionViewCell.self)
manager.register(UICollectionViewListCell.self, for: Model.self, handler: { cell, model, indexPath in })
```

Registering supplementary views to dequeue them from code:

```swift
manager.registerSupplementary(SupplementaryView.self, ofKind: "SupplementaryKind")
manager.registerSupplementary(UICollectionReusableView.self, for: Model.self, ofKind: "SupplementaryKind", handler: { cell, model, indexPath in })

// UICollectionView.elementKindSectionHeader element kind
manager.registerHeader(SupplementaryView.self)
manager.registerHeader(UICollectionReusableView.self, for: Model.self, handler: { view, model, indexPath in })

// UICollectionView.elementKindSectionFooter element kind
manager.registerFooter(SupplementaryView.self)
manager.registerFooter(UICollectionReusableView.self, for: Model.self, handler: { view, model, indexPath in })
```

There's no need to explicitly specify that views are created from code, unless you have a xib file, which name exactly matches name of registered view, in which case you can explicitly set xibName parameter to nil to make sure view is created from code:

```swift
manager.register(CollectionViewCell.self) { mapping in
  mapping.xibName = nil
}
```

## Xib file

Creating views using xib-files follow the same syntax described in previous section, defaulting name of the xib file to the name of registered class. If you need to load view from xib with another name, you can specify that name in the mapping closure:

```swift
// If "PostCell.xib" exists, it will be used
manager.register(PostCell.self)

// If "CustomPostCell.xib" exists, it will be used
manager.register(PostCell.self){ mapping in
  mapping.xibName = "CustomPostCell"
}
```

## Storyboard

Registering views, designed in storyboard, has the same syntax as in two previous sections of this document, however you need to explicitly specify that this view is registered by storyboard inside of mapping closure:

```swift
manager.register(PostCell.self) { mapping in
  mapping.cellRegisteredByStoryboard = true
}

mapping.register(HeaderFooterView.self) { mapping in
  mapping.supplementaryRegisteredByStoryboard = true
}
```
  >This unfortunate verbosity is caused by inability to check, whether view is registered by storyboard or not. If `DTCollectionViewManager` would call registration methods, it would override storyboard registration, and dequeue would simply not work. And if it woudln't, registering views from code will not work. So, those two parameters are lesser evils, since designing views in storyboard is a rare practice, and one I personally would not recommend, as views designed in storyboard are not reusable across other view controllers. Xib files or code views, on the other hand, are.

## Conditional mappings

It's possible to register views to work on specific conditions, such as concrete section, or model condition, which you can read more about in [Conditional mappings guide](Conditional%20mappings.md).

## Compatibility with `UICollectionView.CellRegistration.Handler`

You may notice, that `UICollectionView.CellRegistration.Handler` signature is very similar to `handler` closure on registration methods. They are different however, because `handler` closure has signature `(View, Model, IndexPath) -> Void`, where `UICollectionView.CellRegistration.Handler` has a signature `(View, IndexPath, Model) -> Void`.

Events in `DTCollectionViewManager` had `(View,Model,IndexPath) -> Void` signature for several years, and it would be a massive breaking change to switch arguments just to match `UICollectionView.CellRegistration.Handler`. This also does not make much sense, since `UICollectionView.SupplementaryRegistration` is completely different, and does not event contain a data model.

You can build an adapter to convert `UICollectionView.CellRegistration.Handler` to `handler` signature, but I would not really recommend it, since functionally they are the same and you should not need `UICollectionView.CellRegistration` when using DTCollectionViewManager.

## Can I unregister mappings?

You can unregister cells, headers and footers from `DTCollectionViewManager` and `UICollectionView` by calling:

```swift
manager.unregister(FooCell.self)
manager.unregisterHeader(HeaderView.self)
manager.unregisterFooter(FooterView.self)
manager.unregisterSupplementary(SupplementaryView.self, forKind: "foo")
```

This is equivalent to calling collection view register methods with nil class or nil nib. Please note, that all events tied to specified mapping are also removed.
