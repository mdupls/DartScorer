//
//  PropertiesViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-05.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class PropertiesViewController: UITableViewController {
    
    // MARK: Variables
    
    var config: GameConfig?
    
    var properties: [GameProperty] {
        return config?.properties ?? []
    }
    
    var count: Int {
        return properties.count
    }
    
    // MARK: IBAction
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = config?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProperty" {
            if let viewController = segue.destination as? PropertyViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    viewController.property = properties[indexPath.row]
                }
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        let property = properties[indexPath.row]
        
        if property.type == "boolean" {
            cell = tableView.dequeueReusableCell(withIdentifier: "booleanCell", for: indexPath)
            
            populate(cell: cell as? BooleanTableViewCell, indexPath: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "disclosureCell", for: indexPath)
            
            populate(cell: cell, indexPath: indexPath)
        }
        
        return cell
    }
    
    // MARK: Private
    
    private func populate(cell: BooleanTableViewCell?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        let property = properties[indexPath.row]
        
        cell.titleLabel.text = property.name
        cell.switchView.isOn = (property.value as? Bool) ?? false
    }
    
    private func populate(cell: UITableViewCell?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        let property = properties[indexPath.row]
        
        cell.textLabel?.text = property.name
        
        if let value = property.value {
            cell.detailTextLabel?.text = "\(value)"
        } else {
            cell.detailTextLabel?.text = nil
        }
    }
    
}

class BooleanTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchView: UISwitch!
    
}
