//
//  SCListItemSource.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import Foundation

public protocol SCListItemSource {
    func userIsMe(user: String) -> Bool
    func readOnly() -> Bool
    // create
    func addList(list: SCListViewModel)
    func addItem(inList: Int, item: SCItemViewModel)
    // read
    func numberOfLists() -> Int
    func list(index : Int) -> SCListViewModel
    func numberOfItems(inList: Int) -> Int
    func item(inList: Int, index: Int) -> SCItemViewModel
    func numberOfComments(inList: Int, index: Int) -> Int
    func comment(inList: Int, index: Int, commentIndex: Int) -> SCCommentViewModel
    // update
    func updateList(index: Int, newData: SCListViewModel)
    func updateItem(inList: Int, index: Int, newData: SCItemViewModel)
    func deleteItemComment(inList: Int, index: Int, commentIndex: Int)
    func addItemComment(inList: Int, index: Int, comment: SCCommentViewModel)
    // delete
    func deleteList(index: Int)
    func deleteItem(inList: Int, index: Int)
    // sort
    func sortByModifiedLatestFirst()
}

