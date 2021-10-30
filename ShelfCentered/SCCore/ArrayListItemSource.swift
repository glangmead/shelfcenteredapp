//
//  ArrayListItemSource.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import Foundation
import CloudKit

class ArrayListItemSource : SCListItemSource, CustomStringConvertible {
    var isMe: Bool
    func userIsMe(user: String) -> Bool {
        return user == "Greg"
    }
    var lists : [SCListViewModel]
    var listItems : [[SCItemViewModel]]
    var listItemComments: [[[SCCommentViewModel]]]
    let isReadOnly : Bool
    init(lists: [SCListViewModel], listItems: [[SCItemViewModel]], listItemComments: [[[SCCommentViewModel]]], readOnly: Bool) {
        self.lists = lists
        self.listItems = listItems
        self.listItemComments = listItemComments
        self.isReadOnly = readOnly
        self.isMe = !isReadOnly
    }
    public var description: String {
        var result : String = ""
        for (listIndex, list) in lists.enumerated() {
            result += "list: \(list.name) (\(list.user))\n"
            for item in listItems[listIndex] {
                result += "  \(item.name)\n"
            }
        }
        return result
    }
    func readOnly() -> Bool {
        return self.isReadOnly
    }
    // create
    func addList(list: SCListViewModel) {
        self.lists.append(list)
        self.listItems.append([])
    }
    func addItem(inList: Int, item: SCItemViewModel) {
        self.listItems[inList].append(item)
    }
    // read
    func numberOfLists() -> Int {
        return listItems.count
    }
    func list(index : Int) -> SCListViewModel {
        return lists[index]
    }
    func numberOfItems(inList: Int) -> Int {
        return listItems[inList].count
    }
    func item(inList: Int, index: Int) -> SCItemViewModel {
        return listItems[inList][index]
    }
    public func numberOfComments(inList: Int, index: Int) -> Int {
        return self.listItemComments[inList][index].count
    }
    public func comment(inList: Int, index: Int, commentIndex: Int) -> SCCommentViewModel {
        return self.listItemComments[inList][index][commentIndex]
    }
    // update
    func updateList(index: Int, newData: SCListViewModel) {
        self.lists[index] = newData
    }
    func updateItem(inList: Int, index: Int, newData: SCItemViewModel) {
        self.listItems[inList][index] = newData
    }
    func deleteItemComment(inList: Int, index: Int, commentIndex: Int) {
        listItemComments[inList][index].remove(at: commentIndex)
    }
    func addItemComment(inList: Int, index: Int, comment: SCCommentViewModel) {
        listItemComments[inList][index].append(comment)
    }
    // delete
    func deleteList(index: Int) {
        self.lists.remove(at: index)
    }
    func deleteItem(inList: Int, index: Int) {
        self.listItems[inList].remove(at: index)
    }
    // sort
    func sortByModifiedLatestFirst() {
        for var list in listItems {
            list.sort(by: {$0.modifiedAt.value < $1.modifiedAt.value})
        }
    }
    

    static func getTestSharedItemSource() -> SCListItemSource {
        let myBundle = Bundle(for: ArrayListItemSource.self)
        let suckerPunchImage = UIImage(named: "suckerPunch.jpg", in: myBundle, compatibleWith: nil)

        let suckerPunchItem = SCItemViewModel(name: "Sucker Punch, an item I've always wanted but never bought", image: suckerPunchImage, url: "https://smile.amazon.com/Sucker-Gimmicks-Online-Instructions-Southworth/dp/B01N4GYHMQ/ref=sr_1_10?ie=UTF8&qid=1518628995&sr=8-10&keywords=sucker+punch", description: "", createdAt: Date(), modifiedAt: Date(), claimed: false, editable: false)
        let redFamineItem = SCItemViewModel(name: "Red Famine book", image: UIImage(named:"redFamineBook.jpg", in: myBundle, compatibleWith: nil), url: "", description: "", createdAt: Date(), modifiedAt: Date(), claimed: false, editable: false)
        let bpItem = SCItemViewModel(name: "Black Panther", image: UIImage(named:"blackPantherBook.jpg", in: myBundle, compatibleWith: nil), url: "", description: "", createdAt: Date(), modifiedAt: Date(), claimed: false, editable: false)
        let deskItem = SCItemViewModel(name: "Tummy desk", image: UIImage(named:"tummyDesk.jpg", in: myBundle, compatibleWith: nil), url: "", description: "", createdAt: Date(), modifiedAt: Date(), claimed: false, editable: false)
        
        let shelfItemSource = ArrayListItemSource(
            lists: [SCListViewModel(name: "Birthday 2018", description: "Aw yeah", user: "Mom", createdAt: Date(), modifiedAt: Date()), SCListViewModel(name: "Christmas 2017", description: "Aw yeah", user: "Mom", createdAt: Date(), modifiedAt: Date())],
            listItems: [[suckerPunchItem, redFamineItem], [bpItem, deskItem]],
            listItemComments: [[[], []], [[], []]],
            readOnly: true
        )
        return shelfItemSource
    }

    static func getTestMyItemSource() -> SCListItemSource {
        let myBundle = Bundle(for: ArrayListItemSource.self)
        var laboItem = SCItemViewModel(name: "Labo", image: UIImage(named:"labo.jpg", in: myBundle, compatibleWith: nil), url: "", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit vitae velit sed mollis. Pellentesque sodales consequat urna quis fermentum. Donec arcu urna, suscipit quis fringilla a, venenatis non lectus. Phasellus tristique nulla id sollicitudin auctor. Nunc tincidunt felis sed rutrum fermentum. Sed ullamcorper tincidunt nunc, eu pretium mauris ultricies blandit. Donec faucibus commodo leo, viverra auctor lacus egestas a.")
        let laboComments = [
            SCCommentViewModel(comment: "The Labo looks neat, I wonder if anyone will really play with it or if it'll just sit there unused.", user: "Judgment", editable: true),
            SCCommentViewModel(comment: "Me too. I wonder that.", user: "Greg", editable: false),
            SCCommentViewModel(comment: "Me too. I wonder that.", user: "Jerk2", editable: true),
            SCCommentViewModel(comment: "Me too. I wonder that.", user: "Jerk3", editable: false),
            SCCommentViewModel(comment: "Me too. I wonder that.", user: "Jerk4", editable: false),
            SCCommentViewModel(comment: "Me too. I wonder that.", user: "Jerk5", editable: false),
            SCCommentViewModel(comment: "Me too. I wonder that.", user: "Jerk6", editable: false),
            SCCommentViewModel(comment: "Me too. I wonder that.", user: "Jerk7", editable: false),
            SCCommentViewModel(comment: "Me too. I wonder that.", user: "Jerk8", editable: false)
        ]
        let iceItem = SCItemViewModel(name: "Ice maker", image: UIImage(named:"ice.jpg", in: myBundle, compatibleWith: nil), url: "", description: "")
        let penItem = SCItemViewModel(name: "Pen", image: UIImage(named:"pen.jpg", in: myBundle, compatibleWith: nil), url: "", description: "")
        
        let shelfItemSource = ArrayListItemSource(
            lists: [SCListViewModel(name: "My Birthday 2018", description: "Aw yeah", user: "Me", createdAt: Date(), modifiedAt: Date()), SCListViewModel(name: "My Christmas 2017", description: "Aw yeah", user: "Me", createdAt: Date(), modifiedAt: Date())],
            listItems: [[laboItem, iceItem], [penItem]],
            listItemComments: [[laboComments, []], [[]]],
            readOnly: false
        )
        return shelfItemSource
    }

}
