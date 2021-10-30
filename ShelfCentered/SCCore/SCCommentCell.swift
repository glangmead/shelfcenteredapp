//
//  SCCommentCell.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

class SCCommentCell : UITableViewCell {
    var comment : SCCommentViewModel? = nil {
        didSet {
            self.textLabel!.textBond.bind(comment!.comment)
            // below are two bindings from the comment to the same text label, which means there are two ways it might need to be updated, so that seems snazzy
            self.detailTextLabel!.nameAndDateBondWithDate(comment!.modifiedAt.value).bind(comment!.user)
            self.detailTextLabel!.nameAndDateBondWithName(comment!.user.value).bind(comment!.modifiedAt)
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel!.numberOfLines = 0
        self.textLabel!.lineBreakMode = .byWordWrapping
        //        self.detailTextLabel!.numberOfLines = 1
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
}


