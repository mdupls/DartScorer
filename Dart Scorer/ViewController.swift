//
//  ViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-23.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Variables
    
    var teams: [Team]? {
        didSet {
            gameChooserViewController?.teams = teams
        }
    }
    
    var storage: CoreDataStorage {
        return ((UIApplication.shared.delegate as? AppDelegate)?.storage)!
    }
    
    weak var gameChooserViewController: GameChooserViewController?
    
    // MARK: Unwind Segues
    
    @IBAction func unwindFromPlayerChooser(segue: UIStoryboardSegue) {
        retrieveItems()
    }
    
    @IBAction func unwindFromGameOptions(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: Lifcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveItems()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedGameChooser" {
            gameChooserViewController = segue.destination as? GameChooserViewController
        }
    }
    
    // MARK: Private
    
    private func retrieveItems() {
        let persitence = TeamPersistence(storage: storage)
        teams = persitence.teams()
    }
    
}
