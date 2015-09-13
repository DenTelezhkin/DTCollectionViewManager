//
//  MasterViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage
import DTCollectionViewManager

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let controllers : [(String, AnyClass)] = [("Move sections", SectionsViewController.self),
                        ("Complex layout", ComplexLayoutViewController.self)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controllers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        cell.textLabel?.text = controllers[indexPath.row].0
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let model = controllers[indexPath.row]
        let controllerID = RuntimeHelper.classNameFromReflection(_reflect(model.1))
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(controllerID)
        let navigation = UINavigationController(rootViewController: controller)
        self.splitViewController?.viewControllers = [self, navigation]
    }
}

