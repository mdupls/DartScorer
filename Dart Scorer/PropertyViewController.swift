//
//  PropertyViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-05.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class PropertyViewController: UITableViewController {
    
    // MARK: Variables
    
    var property: GameProperty?
    
    var values: [Any] {
        return property?.values ?? []
    }
    
    var count: Int {
        return values.count
    }
    
    var selectedIndex: Int? {
        if let index = _selectedIndex {
            return index
        }
        
        if let selectedValue = property?.value {
            for (index, value) in values.enumerated() {
                if (value as AnyObject).isEqual(selectedValue) {
                    _selectedIndex = index
                    return index
                }
            }
        }
        return nil
    }
    
    private var _selectedIndex: Int?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = property?.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if count > 0, let index = selectedIndex {
            let indexPath = IndexPath(row: index, section: 0)
            
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldIndex = selectedIndex
        _selectedIndex = indexPath.row
        
        if let index = oldIndex {
            // Uncheck the previously selected row and check the new row.
            tableView.reloadRows(at: [indexPath, IndexPath(row: index, section: 0)], with: .automatic)
        } else {
            // Check the newly selected row.
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        // Update the property.
        property?.value = values[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
        
        populate(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: Private
    
    private func populate(cell: UITableViewCell?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        let value = values[indexPath.row]
        
        cell.textLabel?.text = "\(value)"
        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
    }
    
}
