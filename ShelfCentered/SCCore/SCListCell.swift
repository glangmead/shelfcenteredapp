//
//  SCListCell.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

class SCListCell : UITableViewCell {
    var list : SCListViewModel = SCListViewModel() {
        didSet {
            self.textLabel!.textBond.bind(list.name)
            self.detailTextLabel!.textBond.bind(list.user)
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
}


