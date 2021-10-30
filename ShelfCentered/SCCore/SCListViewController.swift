//
//  SCListViewController.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

class SCListViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let listItemSource : SCListItemSource
    let listIndex : Int
    let navCoordinator : SCNavigationCoordinator
    let reuseIdentifier = "ItemCell"

    init(listItemSource: SCListItemSource, listIndex : Int, navCoordinator : SCNavigationCoordinator) {
        self.listItemSource = listItemSource
        self.listIndex = listIndex
        self.navCoordinator = navCoordinator
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.titleBond.bind(listItemSource.list(index: listIndex).name)
        if (!self.listItemSource.readOnly()) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(SCItemCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
    }
    @objc func addButtonPressed() {
        listItemSource.addItem(inList: self.listIndex, item: SCItemViewModel(name: "Item \(self.listItemSource.numberOfItems(inList: self.listIndex) + 1)", image: nil, url: "", description: ""))
        self.listItemSource.sortByModifiedLatestFirst()
        self.collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navCoordinator.itemSelected(source: self.listItemSource, listIndex: self.listIndex, itemIndex: indexPath.row, fromVC: self)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItemSource.numberOfItems(inList: listIndex)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SCItemCell
        cell.updateWithItem(newItem: listItemSource.item(inList: listIndex, index: indexPath.row))
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right), height: 470)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
}

