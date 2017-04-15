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
    
    var teams: [Team]?
    var bench: [Player]?
    
    var storage: CoreDataStorage {
        return ((UIApplication.shared.delegate as? AppDelegate)?.storage)!
    }
    
    private var leftBarButtonItems: [UIBarButtonItem]?
    private var rightBarButtonItems: [UIBarButtonItem]?
    private var toolbarButtonItems: [UIBarButtonItem]?
    
    internal override var isEditing: Bool {
        didSet {
            collectionView?.allowsSelection = isEditing
            collectionView?.allowsMultipleSelection = isEditing
            
            if isEditing {
                navigationItem.leftBarButtonItems = nil
                navigationItem.rightBarButtonItems = [doneEditBarButtonItem]
                
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                toolbarItems = [newTeamBarButtonItem, flexibleSpace, deleteBarButtonItem]
                
                updateToolbar()
            } else {
                navigationItem.leftBarButtonItems = [doneBarButtonItem]
                navigationItem.rightBarButtonItems = [editBarButtonItem]
                
                toolbarItems = [newPlayerBarButtonItem]
            }
        
            updateTitle()
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneEditBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var newPlayerBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var newTeamBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var deleteBarButtonItem: UIBarButtonItem!
    
    // MARK: IBActions
    
    @IBAction func didTapEdit(sender: UIBarButtonItem) {
        isEditing = true
    }
    
    @IBAction func didTapDoneEditing(sender: UIBarButtonItem) {
        isEditing = false
    }
    
    @IBAction func didTapNewPlayer(sender: UIBarButtonItem) {
        askForName(title: "Create Player") {
            self.isEditing = false
            
            if let name = $0, !name.isEmpty {
                let persitence = PlayerPersistence(storage: self.storage)
                if let player = persitence.createPlayer(with: name) {
                    let position = self.bench?.count ?? 0
                    self.bench?.append(player)
                    self.collectionView?.insertItems(at: [IndexPath(item: position, section: 1)])
                    self.editBarButtonItem?.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func didTapNewTeam(sender: UIBarButtonItem) {
        if let players = selectedBench() {
            if players.count > 1 {
                askForName(title: "Create Team") {
                    self.isEditing = false
                    
                    if let name = $0, !name.isEmpty {
                        let teamPersistence = TeamPersistence(storage: self.storage)
                        if let team = teamPersistence.createTeam(name: name, players: players) {
                            let position = self.teams?.count ?? 0
                            self.teams?.append(team)
                            self.collectionView?.insertItems(at: [IndexPath(item: position, section: 0)])
                            self.editBarButtonItem?.isEnabled = true
                        }
                    }
                }
            } else {
                self.isEditing = false
                
                let teamPersistence = TeamPersistence(storage: self.storage)
                if let team = teamPersistence.createTeam(players: players) {
                    let position = self.teams?.count ?? 0
                    self.teams?.append(team)
                    self.collectionView?.insertItems(at: [IndexPath(item: position, section: 0)])
                    self.editBarButtonItem?.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func didTapDelete(sender: UIBarButtonItem) {
        let players = selectedBench()
        let teams = selectedTeams()
        var hasDeleted: Bool = false
        
        if let players = players, !players.isEmpty {
            let playerPersistence = PlayerPersistence(storage: storage)
            playerPersistence.delete(players: players)
            
            hasDeleted = true
        }
        
        if let teams = teams, !teams.isEmpty {
            let teamPersistence = TeamPersistence(storage: storage)
            teamPersistence.delete(teams: teams)
            
            hasDeleted = true
        }
        
        if hasDeleted {
            retrieveItems()
            collectionView?.reloadData()
        }
        
        isEditing = false
    }
    
    // MARK: Lifcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editBarButtonItem.isEnabled = false
        
        leftBarButtonItems = navigationItem.leftBarButtonItems
        rightBarButtonItems = navigationItem.rightBarButtonItems
        toolbarButtonItems = toolbarItems
        
        // Start in the non-edit mode.
        isEditing = false
        
        retrieveItems()
    }
    
    deinit {
        leftBarButtonItems = nil
        rightBarButtonItems = nil
        toolbarButtonItems = nil
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateTitle()
        updateToolbar()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateTitle()
        updateToolbar()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return teams?.count ?? 0
        case 1:
            return bench?.count ?? 0
        default:
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        var hasMultiplePlayers: Bool = false
        var onlyTeamPlayer: Player?
        
        if indexPath.section == 0 {
            // A team cell should have more than one player.
            hasMultiplePlayers = (teams?[indexPath.row].players?.count ?? 0) > 1
            
            if !hasMultiplePlayers {
                onlyTeamPlayer = teams?[indexPath.row].players?.firstObject as? Player
            }
        }
        
        if hasMultiplePlayers {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "teamCell", for: indexPath)
            populate(cell: cell as? TeamCollectionViewCell, indexPath: indexPath)
        } else {
            let player = onlyTeamPlayer ?? bench?[indexPath.row]
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerCell", for: indexPath)
            populate(cell: cell as? PlayerCollectionViewCell, player: player, indexPath: indexPath)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            
            populate(header: headerView as? PlayersHeaderCell, indexPath: indexPath)
            
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return size()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return inset()
    }
    
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
    
    private func populate(cell: TeamCollectionViewCell?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        let team = teams?[indexPath.row]
        
        cell.team = team
        cell.nameLabel.text = team?.teamName
    }
    
    private func populate(cell: PlayerCollectionViewCell?, player: Player?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.nameLabel.text = player?.name
    }
    
    private func populate(header: PlayersHeaderCell?, indexPath: IndexPath) {
        guard let header = header else { return }
        
        if indexPath.section == 0 {
            header.nameLabel.text = "Game Opponents"
        } else if indexPath.section == 1 {
            header.nameLabel.text = "Bench"
        }
    }
    
    private func askForName(title: String, message: String? = nil, completion: @escaping (_ name: String?) -> ()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            alert -> Void in
            
            if let name = alertController.textFields?.first?.text {
                completion(name)
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
    
    private func updateTitle() {
        if isEditing {
            let selectedCount = collectionView?.indexPathsForSelectedItems?.count ?? 0
            if selectedCount > 0 {
                title = "1 Selected"
            } else {
                title = "Select Items"
            }
        } else {
            title = "Players"
        }
    }
    
    private func updateToolbar() {
        guard isEditing else { return }
        
        let selectedCount = collectionView?.indexPathsForSelectedItems?.count ?? 0
        newTeamBarButtonItem?.isEnabled = selectedCount > 0
        deleteBarButtonItem?.isEnabled = selectedCount > 0
    }
    
    private func retrieveItems() {
        let playerPersistence = PlayerPersistence(storage: storage)
        bench = playerPersistence.players()
        
        let teamPersistence = TeamPersistence(storage: storage)
        teams = teamPersistence.teams()
        
        let benchCount = bench?.count ?? 0
        let teamCount = teams?.count ?? 0
        
        editBarButtonItem.isEnabled = benchCount > 0 || teamCount > 0
    }
    
    private func selectedBench() -> [Player]? {
        var players: [Player] = []
        
        collectionView?.indexPathsForSelectedItems?.forEach {
            if $0.section == 1 {
                players.append(self.bench![$0.row])
            }
        }
        
        return players.isEmpty ? nil : players
    }
    
    private func selectedTeams() -> [Team]? {
        var teams: [Team] = []
        
        collectionView?.indexPathsForSelectedItems?.forEach {
            if $0.section == 0 {
                teams.append(self.teams![$0.row])
            }
        }
        
        return teams.isEmpty ? nil : teams
    }
    
}
