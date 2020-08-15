//
//  SceneDelegate.swift
//  Example
//
//  Created by Denys Telezhkin on 14.08.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // MARK: - UIWindowSceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let splitView = UISplitViewController(style: .doubleColumn)
        splitView.setViewController(MasterViewController(), for: .primary)
        splitView.setViewController(pleaseSelectExampleViewController, for: .secondary)
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = splitView
        window?.makeKeyAndVisible()
    }
    
    private var pleaseSelectExampleViewController: UIViewController {
        let controller = UIViewController()
        let label = UILabel()
        label.text = "Please select one of the examples in a side menu"
        controller.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
        ])
        return controller
    }
}
