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
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controllers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = controllers[(indexPath as NSIndexPath).row].0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = controllers[(indexPath as NSIndexPath).row]
        let controllerID = String(describing: model.1)
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: controllerID)
        let navigation = UINavigationController(rootViewController: controller)
        self.splitViewController?.viewControllers = [self, navigation]
    }
}

