//
//  SCNavigationCoordinator.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

struct SCNavigationCoordinator {
    let navC : UINavigationController
    func itemSelected(source: SCListItemSource, listIndex: Int, itemIndex: Int, fromVC: UIViewController) {
        let itemVC = SCItemViewController(source: source, listIndex: listIndex, itemIndex: itemIndex)
        itemVC.navCoordinator = self
        navC.pushViewController(itemVC, animated: true)
    }
    func listSelected(source: SCListItemSource, listIndex: Int, fromVC: UIViewController) {
        navC.pushViewController(SCListViewController(listItemSource: source, listIndex: listIndex, navCoordinator: self), animated: true)
    }
    func itemEditing(source: SCListItemSource, listIndex: Int, itemIndex: Int, fromVC: UIViewController) {
        navC.pushViewController(SCEditItemViewController(source: source, listIndex: listIndex, itemIndex: itemIndex), animated: true)
    }
}


