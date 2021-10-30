//
//  CKListItemSource.swift
//  SCCore
//
//  Created by Greg Langmead on 10/14/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import Foundation
import CloudKit

extension CKAsset {
    convenience init(image: UIImage, compression: CGFloat) {
        let fileURL = ImageHelper.saveToDisk(image: image, compression: compression)
        self.init(fileURL: fileURL)
    }
    
    var image: UIImage? {
        guard let data = try? Data(contentsOf: fileURL),
            let image = UIImage(data: data) else {
                return nil
        }
        
        return image
    }
}

public class CKListItemSource : SCListItemSource, CustomStringConvertible {
    let isMe : Bool
    var lists : [SCListViewModel]
    var listCKRecords : [CKRecord]
    var listItems : [[SCItemViewModel]]
    var listItemCKRecords : [[CKRecord]]
    var listItemComments : [[[SCCommentViewModel]]]
    var listItemCommentCKRecords : [[[CKRecord]]]

    let isReadOnly : Bool
    let db : CKDatabase
    let zoneID : CKRecordZone.ID
    
    public init(db : CKDatabase, zoneID: CKRecordZone.ID, isMe: Bool) {
        self.isMe = isMe
        self.isReadOnly = !isMe
        self.lists = []
        self.listItems = []
        self.listItemComments = []
        self.listCKRecords = []
        self.listItemCKRecords = []
        self.listItemCommentCKRecords = []
        
        self.db = db
        self.zoneID = zoneID
        fetchLists()
    }
    
    private func fetchLists() {
        let myListsQuery = CKQuery(recordType: "Lists", predicate: NSPredicate(format: "TRUEPREDICATE"))
        //myListsQuery.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        self.db.perform(myListsQuery, inZoneWith: self.zoneID, completionHandler: { (records, error) in
            if records != nil {
                self.lists = records!.map {
                    return self.listViewModelFromCKRecord($0)
                }
                self.listCKRecords = records!
                
                // make empty list items to be filled in lazily
                self.listItems = Array.init(repeating: [], count: self.lists.count)
                self.listItemCKRecords = Array.init(repeating: [], count: self.lists.count)
                self.listItemComments = Array.init(repeating: [], count: self.lists.count)
                self.listItemCommentCKRecords = Array.init(repeating: [], count: self.lists.count)

                for (i, listRecord) in self.listCKRecords.enumerated() {
                    self.fetchItemsForList(listID: listRecord.recordID, listIndex: i)
                }
            }
        })
    }
    private func fetchItemsForList(listID : CKRecord.ID, listIndex : Int) {
        //let listReference = CKRecord.Reference(recordID: listID, action: .none)
        let query = CKQuery(recordType: "Items", predicate: NSPredicate(format: "lists CONTAINS %@", listID))
        db.perform(query, inZoneWith: self.zoneID, completionHandler: { (records, error) in
            if records != nil {
                let items = records!.map {
                    return self.listItemViewModelFromCKRecord($0)
                }
                self.listItems[listIndex] = items
                self.listItemCKRecords[listIndex] = records!
                
                self.listItemComments[listIndex] = Array.init(repeating: [], count: items.count)
                self.listItemCommentCKRecords[listIndex] = Array.init(repeating: [], count: items.count)
                
                for (i, itemRecord) in records!.enumerated() {
                    self.fetchCommentsForItem(itemID: itemRecord.recordID, listIndex: listIndex, itemIndex: i)
                }
            }
        })
    }

    private func fetchCommentsForItem(itemID : CKRecord.ID, listIndex: Int, itemIndex: Int) {
        let query = CKQuery(recordType: "Comments", predicate: NSPredicate(format: "item == %@", itemID))
        db.perform(query, inZoneWith: self.zoneID, completionHandler: { (records, error) in
            if records != nil {
                let comments = records!.map {
                    return CKListItemSource.commentViewModelFromCKRecord($0)
                }
                self.listItemComments[listIndex][itemIndex] = comments
                self.listItemCommentCKRecords[listIndex][itemIndex] = records!
            }
        })
    }

    private func listItemViewModelFromCKRecord(_ record: CKRecord) -> SCItemViewModel {
        let item = SCItemViewModel(
            name: record["name"] ?? "",
            image: nil,
            url: record["url"] ?? "",
            description: record["description"] ?? "",
            createdAt: record.creationDate!,
            modifiedAt: record.modificationDate!,
            claimed: false,
            editable: self.isMe
        )
        if let asset = record["image"] as? CKAsset, let data = try? Data(contentsOf: asset.fileURL) {
            DispatchQueue.main.async {
                item.image.value = UIImage(data: data)
            }
        }
        return item
    }
    
    private func listViewModelFromCKRecord(_ record: CKRecord) -> SCListViewModel {
        let list = SCListViewModel(
            name: record["name"]!,
            description: record["description"]!,
            user: "TODO",
            createdAt: record.creationDate!,
            modifiedAt: record.modificationDate!
        )
        return list
    }
    
    private static func commentViewModelFromCKRecord(_ record: CKRecord) -> SCCommentViewModel {
        return SCCommentViewModel(comment: record["comment"]!, user: "TODO", createdAt: record.creationDate!, modifiedAt: record.modificationDate!, editable: false)
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
    public func userIsMe(user: String) -> Bool {
        return false
    }
    public func readOnly() -> Bool {
        return self.isReadOnly
    }
    // create
    public func addList(list: SCListViewModel) {
        self.lists.append(list)
        self.listItems.append([])
        self.listItemCKRecords.append([])
        self.listItemComments.append([])
        self.listItemCommentCKRecords.append([])
        let newCKList = CKRecord(recordType: "Lists", zoneID: self.zoneID)
        newCKList["name"] = list.name.value
        newCKList["description"] = list.description.value
        self.db.save(newCKList, completionHandler: { (record, error) in
            if (record != nil) {
                self.listCKRecords.append(record!)
            }
            if (error != nil) {
                print(error!)
            }
        })
    }
    public func addItem(inList: Int, item: SCItemViewModel) {
        self.listItems[inList].append(item)
        self.listItemComments[inList].append([])
        let newCKListItem = CKRecord(recordType: "Items", zoneID: self.zoneID)
        newCKListItem["name"] = item.name.value
        newCKListItem["description"] = item.description.value
        newCKListItem["url"] = item.url.value
        // link item to list via cloudkit parent relationship
        newCKListItem.setParent(self.listCKRecords[inList])
        if (item.image.value != nil) {
            newCKListItem["image"] = CKAsset(image: item.image.value!, compression: 1.0)
        }
        self.db.save(newCKListItem, completionHandler: { (record, error) in
            if (record != nil) {
                self.listItemCKRecords[inList].append(record!)
                self.listItemCommentCKRecords[inList].append([])
            }
            if (error != nil) {
                print(error!)
            }
        })
        
    }
    public func addItemComment(inList: Int, index: Int, comment: SCCommentViewModel) {
        self.listItemComments[inList][index].append(comment)
        let newCKComment = CKRecord(recordType: "Comments", zoneID: self.zoneID)
        newCKComment["comment"] = comment.comment.value
        newCKComment["item"] = CKRecord.Reference(record: self.listItemCKRecords[inList][index], action: .deleteSelf)
        newCKComment.setParent(self.listItemCKRecords[inList][index])
        self.db.save(newCKComment, completionHandler: { (record, error) in
            if (record != nil) {
                self.listItemCommentCKRecords[inList][index].append(record!)
            }
            if (error != nil) {
                print(error!)
            }
        })
    }
    // read
    public func numberOfLists() -> Int {
        return self.lists.count
    }
    public func list(index : Int) -> SCListViewModel {
        return self.lists[index]
    }
    public func numberOfItems(inList: Int) -> Int {
        return self.listItems[inList].count
    }
    public func item(inList: Int, index: Int) -> SCItemViewModel {
        return self.listItems[inList][index]
    }
    public func numberOfComments(inList: Int, index: Int) -> Int {
        return self.listItemComments[inList][index].count
    }
    public func comment(inList: Int, index: Int, commentIndex: Int) -> SCCommentViewModel {
        return self.listItemComments[inList][index][commentIndex]
    }
    // update
    public func updateList(index: Int, newData: SCListViewModel) {
        self.lists[index] = newData
        let listCKRecord = self.listCKRecords[index]
        listCKRecord["name"] = newData.name.value
        listCKRecord["description"] = newData.description.value
        self.db.save(listCKRecord, completionHandler: {(record, error) in
            
        })
    }
    public func updateItem(inList: Int, index: Int, newData: SCItemViewModel) {
        self.listItems[inList][index] = newData
        let itemCKRecord = self.listItemCKRecords[inList][index]
        itemCKRecord["name"] = newData.name.value
        itemCKRecord["description"] = newData.description.value
        itemCKRecord["url"] = newData.url.value
        if (newData.image.value != nil) {
            itemCKRecord["image"] = CKAsset(image: newData.image.value!, compression: 1.0)
        }
        self.db.save(itemCKRecord, completionHandler: {(record, error) in
            if (error != nil) {
                print(error!)
            }
        })
    }
    // delete
    public func deleteList(index: Int) {
        self.db.delete(withRecordID: self.listCKRecords[index].recordID, completionHandler: {(id, error) in
            if (id != nil) {
                self.listCKRecords.remove(at: index)
            }
            if (error != nil) {
                print(error!)
            }
        })
        self.lists.remove(at: index)
        self.listItems.remove(at: index)
        self.listItemCKRecords.remove(at: index)
        self.listItemComments.remove(at: index)
        self.listItemCommentCKRecords.remove(at: index)
    }
    public func deleteItem(inList: Int, index: Int) {
        self.db.delete(withRecordID: self.listItemCKRecords[inList][index].recordID, completionHandler: {(id, error) in
            if (id != nil) {
                self.listItemCKRecords[inList].remove(at: index)
            }
            if (error != nil) {
                print(error!)
            }
        })
        self.listItems[inList].remove(at: index)
        self.listItemComments[inList].remove(at: index)
        self.listItemCommentCKRecords[inList].remove(at: index)
    }
    public func deleteItemComment(inList: Int, index: Int, commentIndex: Int) {
        self.db.delete(withRecordID: self.listItemCommentCKRecords[inList][index][commentIndex].recordID, completionHandler: {(id, error) in
            if (id != nil) {
                self.listItemCommentCKRecords[inList][index].remove(at: commentIndex)
            }
            if (error != nil) {
                print(error!)
            }
        })
        self.listItemComments[inList][index].remove(at: commentIndex)
    }
    // sort
    public func sortByModifiedLatestFirst() {
        
    }

}
