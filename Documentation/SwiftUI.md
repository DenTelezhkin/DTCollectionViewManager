# SwiftUI in UICollectionViewCells

`DTCollectionViewManager` introduces support for rendering SwiftUI views in UICollectionViewCells starting with 11.x release.  Registering SwiftUI view is done similarly to registering usual cells:

```swift
manager.registerHostingCell(for: Post.self) { model, indexPath in
    PostSwiftUICell(model: model)
}
```

This functionality is supported on iOS 13 + / tvOS 13+ / macCatalyst 13+. It's important to understand, that this method of showing SwiftUI views in table / collection view cells is not supported by Apple, and has some hacks implemented to make it work.

Implementation for iOS 16+ method of showing SwiftUI views via hosting configuration (https://developer.apple.com/documentation/SwiftUI/UIHostingConfiguration) is hopefully coming a bit later.

Registration of SwiftUI views follows the same pattern as registering other collection view cells, however there are some important distinctions:

* SwiftUI lifecycle management is done by special subclass of UICollectionViewCell - `HostingCollectionViewCell`, provided by `DTCollectionViewManager`.
* SwiftUI views need to be hosted in UIHostingController, which needs to be added as a child to view controller hierarchy, or appearance and sizing methods will not work in SwiftUI view. This is done automatically by `HostingCollectionViewCell`, but may have some unintended consequences, which you can read about below.
* Because SwiftUI views are generally self-sizing, it's recommended to use this approach with self-sizing UICollectionView cells.

Let's dive into those topics, as they are important to understand how to use this approach correctly.

# UIHostingController hacks

When SwiftUI view (it's UIHostingController) is added to view controller hierarchy, it tries to control several things that may be surprizing in context of UICollectionViewCell content:

* Navigation bar appearance
* Keyboard avoidance / safe area insets
* Other view controller behaviors I did not encounter yet

For example, in the app I'm working on, adding such hosted cell in view controller that had navigation bar hidden, immediately forced navigation bar to appear. In order to fix this problem, `DTCollectionViewManager` provides a way to customize `UIHostingController` used to host collection view cells.

To always hide navigation bar in my view hierarchy, I implemented following subclass of UIHostingController (full credit to this answer on [StackOverflow answer](https://stackoverflow.com/questions/57627641/add-swiftui-view-to-an-uitableviewcell-contentview/68624676#68624676):

```swift
class ControlledNavigationHostingController<Content: View>: UIHostingController<Content> {

    public override init(rootView: Content) {
        super.init(rootView: rootView)
    }

    @objc dynamic required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}
```

Using this subclass with `DTCollectionViewManager` requires modifiying hosting configuration, available via mapping closure:

```swift
manager.registerHostingCell(for: Post.self) { model, _ in
    PostSwiftUICell(model: model)
} mapping: { mapping in
    mapping.configuration.hostingControllerMaker = {
        ControlledNavigationHostingController(rootView: $0) 
    }
}
```

I'm assuming other potential issues, like keyboard avoidance, can also be solved by custom UIHostingController subclass, or swizzling UIHostingController methods. For example, here is [great article by Peter Steinberger](https://steipete.com/posts/disabling-keyboard-avoidance-in-swiftui-uihostingcontroller/), that shows how to disable keyboard avoidance for SwiftUI views embedded in table view or collection view cells.

# Parent view controller

`HostingCollectionViewCell` requires parent view controller to add SwiftUI to view controller hierarchy. `DTCollectionViewManager` provides default parent view controller by typecasting `DTCollectionViewManageable` instance to UIViewController type. If your class implementing `DTCollectionViewManageable` is a view controller, you don't need to do anything.

However, if `DTCollectionViewManageable` instance is not a view controller, you would need to specify parent view controller explicitly in mapping closure:
```swift
mapping.configuration.parentController = customParentViewController
```

# Determining cell size

Because SwiftUI views are generally self-sized, it's recommended to use self-sizing collection view with them. To do that, use automatic size for cells, for example for flow layout:

```swift
flowLayout.estimatedItemSize = UICollectionFlowLayout.automaticSize
```

If you can't or don't want to use automatic cell sizing, make sure SwiftUI view and cells have equal (and fixed) sizes, otherwise SwiftUI and autolayout system may fight and produce unexpected results.

# Cell state and tap events

While `HostingCollectionViewCell` hosts SwiftUI view, it does not communicate to `UICollectionView` with any special information on doing so. So, if for example, you simultaneously implement SwiftUI.Button in a cell, and .didSelect event (`collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)`), they will not play together nicely.

Instead, consider implementing `.onTapGesture` modifier on SwiftUI view and passing events through it's data model (view model would probably fit better here).

# Customizing hosting cell

`HostingCollectionViewCell` is designed to be just a container for SwiftUI view, so all it's views have background of UIColor.clear by default. If you need, you can customize colors of the cell using configuration:

```swift
mapping.configuration.backgroundColor = customColor
mapping.configuration.contentViewBackgroundColor = customColor
mapping.configuration.hostingViewBackgroundColor = customColor
```

If you need any other changes on `HostingCollectionViewCell`, you can also provide a closure, that is run after all cell updates:

```swift
mapping.configuration.configureCell = { cell in
   // Customize cell
}
```

# Perfomance

Each cell creates only one hosting controller, that is reused when cell is updated with new data.

In order to preserve perfomance, background colors are set only once when cell is first created. When cell is being reused, only `configureCell` closure is called on each cell update.

# Is it worth it?

I leave answer to this question for your consideration, since Apple does not support this, and some hacks may be required to work with hosted cells.

For me, however, it was 100% worth it. Live previewing cells in different view states is super helpful in implementing complex views, and is overall much simpler and efficient than doing it in UIKit.

# What about delegate methods for hosted cells?

SwiftUI hosted cells support all delegate methods implemenented for non-hosted cells, for example:

```swift
manager.registerHostingCell(for: Post.self) { model, _ in
    PostSwiftUICell(model: model)
} mapping: { mapping in
    mapping.willDisplay { cell, model, indexPath in
    
    }
}
```

# Can I use SwiftUI in supplementary views?

It seems possible, and code infrastructure is prepared to implement SwiftUI views in supplementary views, but I'm not rushing there yet. It's possible there might be some more hacks there, and I'm not sure at this point, if it's worth doing that, since Apple only introduced support for cells in iOS 16, not supplementary views.

However, I might reconsider this, if there's demand for this feature.

# Is UIHostingConfiguration supported on iOS 16 and higher?

UIHostingConfiguration on iOS 16 is supported by additional registration method:

```swift
manager.registerHostingConfiguration(for: Post.self) { cell, post, indexPath in
    UIHostingConfiguration {
        PostView(post: post)
    }
}
```

Because this is officially supported way of integrating SwiftUI with table and collection view cells, I highly recommend watching [WWDC 2022 session video](https://developer.apple.com/videos/play/wwdc2022/10072/) on this topic. 

All customization options for UIHostingConfiguration is fully supported, for example you can customize margins for cells content:

```swift
manager.registerHostingConfiguration(for: Post.self) { cell, post, indexPath in
    UIHostingConfiguration {
        PostView(post: post)
    }.margins(.horizontal, 16)
}
```

Additionally, you can also use `UICellConfigurationState` of a cell by simply adding one additional parameter:

```
manager.registerHostingConfiguration(for: Post.self) { state, cell, post, indexPath in
    UIHostingConfiguration {
        PostView(post: post, isSelected: state.isSelected)
    }
}
```
