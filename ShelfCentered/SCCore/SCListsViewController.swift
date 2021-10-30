//
//  SCListsViewController.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

class SCListsViewController : UITableViewController {
    let listCellReuseIdentifier = "ListCell"
    let listItemSource : SCListItemSource
    var navCoordinator : SCNavigationCoordinator? = nil
    
    init(listItemSource: SCListItemSource) {
        self.listItemSource = listItemSource
        super.init(style: .plain)
        if (!self.listItemSource.readOnly()) {
            self.navigationItem.rightBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed(sender:))),
                UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(sender:)))
            ]
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    @objc func addButtonPressed(sender:UIBarButtonItem!) {
        listItemSource.addList(list: SCListViewModel(name: "New List \(listItemSource.numberOfLists() + 1)", description: "Description", user: "Me", createdAt: Date(), modifiedAt: Date()))
        self.tableView.reloadData()
    }
    @objc func editButtonPressed(sender:UIBarButtonItem!) {
        self.tableView.isEditing = true
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(sender:))),
        ]
    }
    @objc func doneButtonPressed(sender:UIBarButtonItem!) {
        self.tableView.isEditing = false
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed(sender:))),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(sender:)))
        ]
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItemSource.numberOfLists()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: listCellReuseIdentifier)
        if (cell == nil) {
            cell = SCListCell(style: .subtitle, reuseIdentifier: listCellReuseIdentifier)
        }
        let list = listItemSource.list(index: indexPath.row)
        (cell as! SCListCell).list = list
        return cell!
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navCoordinator!.listSelected(source: self.listItemSource, listIndex: indexPath.row, fromVC: self)
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !listItemSource.readOnly()
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
            self.listItemSource.deleteList(index: indexPath.row)
            tableView.reloadData()
        }
        return [deleteAction]
    }
}


