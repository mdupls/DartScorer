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
            opponentsViewController?.teams = teams
            gameChooserViewController?.teams = teams
        }
    }
    
    var storage: CoreDataStorage {
        return ((UIApplication.shared.delegate as? AppDelegate)?.storage)!
    }
    
    weak var opponentsViewController: OpponentsViewController?
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPlayers" {
            opponentsViewController = segue.destination as? OpponentsViewController
        } else if segue.identifier == "embedGameChooser" {
            gameChooserViewController = segue.destination as? GameChooserViewController
        }
    }
    
    // MARK: Private
    
    private func retrieveItems() {
        let persitence = TeamPersistence(storage: storage)
        teams = persitence.teams()
    }
    
}
