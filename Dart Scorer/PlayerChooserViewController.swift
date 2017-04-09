//
//  PlayerChooserViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-03.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class PlayerChooserViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: Variables
    
    private let visibleItems: Int = 3
    
    var players: [Player]? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var count: Int {
        return players?.count ?? 0
    }
    
    var storage: CoreDataStorage {
        return ((UIApplication.shared.delegate as? AppDelegate)?.storage)!
    }
    
    // MARK: IBActions
    
    @IBAction func didTapCreatePlayer(sender: UIBarButtonItem) {
        askForName() {
            if let name = $0 {
                let persitence = PlayerPersistence(storage: self.storage)
                if let player = persitence.createPlayer(with: name) {
                    self.players?.append(player)
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    // MARK: Lifcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "done" {
            if let destination = segue.destination as? ViewController {
                destination.players = players
            }
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        collectionView.moveItem(at: destinationIndexPath, to: sourceIndexPath)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerCell", for: indexPath)
        
        populate(cell: cell as? PlayerCollectionViewCell, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return size()
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return inset()
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing()
    }
    
    // MARK: Private
    
    private func update() {
        collectionView?.reloadData()
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    private func size() -> CGSize {
        let dimension = 100
        
        return CGSize(width: dimension, height: dimension)
    }
    
    private func inset() -> UIEdgeInsets {
        let horizontalInset: CGFloat = lineSpacing()
        let verticalInset: CGFloat = lineSpacing()
        
        return UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
    }
    
    private func lineSpacing() -> CGFloat {
        return 20
    }
    
    private func spacing() -> CGFloat {
        return 20
    }
    
    private func populate(cell: PlayerCollectionViewCell?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.nameLabel.text = players?[indexPath.row].name
    }
    
    private func askForName(completion: @escaping (_ name: String?) -> ()) {
        let alertController = UIAlertController(title: "Create Player", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            alert -> Void in
            
            if let name = alertController.textFields?.first?.text {
                if name.isEmpty {
                    self.displayMessage(title: "Unable to Create Player", message: "A player must have a name.") {
                        self.askForName(completion: completion)
                    }
                } else {
                    let contains = self.players?.contains(where: { (player) -> Bool in
                        return player.name == name
                    })
                    
                    if contains ?? false {
                        self.displayMessage(title: "Unable to Create Player", message: "A player with that name already exists.") {
                            self.askForName(completion: completion)
                        }
                    } else {
                        completion(name)
                    }
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Player Name"
            textField.keyboardType = .default
            textField.autocapitalizationType = .words
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayMessage(title: String, message: String, completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            alert -> Void in
            
            completion()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
