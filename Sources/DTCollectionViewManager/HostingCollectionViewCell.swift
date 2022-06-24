//
//  HostingCollectionViewCell.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 24.06.2022.
//  Copyright © 2022 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import SwiftUI


// swiftlint:disable missing_docs

@available(iOS 13, tvOS 13, *)
open class HostingCollectionViewCell<Content: View, Model>: UICollectionViewCell {

    private var hostingController: UIHostingController<AnyView>?
    
    open func updateWith(rootView: Content, configuration: HostingCollectionViewCellConfiguration) {
        if let existingHosting = hostingController {
            existingHosting.rootView = AnyView(rootView)
            hostingController?.view.invalidateIntrinsicContentSize()
        } else {
            let hosting = configuration.hostingControllerMaker(AnyView(rootView))
            hostingController = hosting
            if let backgroundColor = configuration.backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let hostingBackgroundColor = configuration.hostingViewBackgroundColor {
                hostingController?.view.backgroundColor = hostingBackgroundColor
            }
            if let contentViewBackgroundColor = configuration.contentViewBackgroundColor {
                contentView.backgroundColor = contentViewBackgroundColor
            }
            
            hostingController?.view.invalidateIntrinsicContentSize()
            
            hosting.willMove(toParent: configuration.parentController)
            configuration.parentController?.addChild(hosting)
            contentView.addSubview(hosting.view)
            
            hosting.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hosting.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                hosting.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            hosting.didMove(toParent: configuration.parentController)
            
            configuration.configureCell(self)
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        hostingController = nil
    }

}
