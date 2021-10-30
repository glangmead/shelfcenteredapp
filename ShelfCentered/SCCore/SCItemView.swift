//
//  SCItemView.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

class SCItemView : UIStackView {
    let imageView : UIImageView
    let itemTitle : UILabel
    let url : UILabel
    let createdAt : UILabel
    let modifiedAt : UILabel
    let descriptionLabel : UILabel
    let listItemSource : SCListItemSource
    let listIndex : Int
    let itemIndex : Int
    init(source: SCListItemSource, listIndex: Int, itemIndex: Int) {
        self.imageView = UIImageView()
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.itemTitle = UILabel()
        self.itemTitle.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        self.itemTitle.textAlignment = .left
        self.itemTitle.numberOfLines = 0 // activates multiline
        self.itemTitle.translatesAutoresizingMaskIntoConstraints = false
        self.url = UILabel()
        self.url.translatesAutoresizingMaskIntoConstraints = false
        self.url.lineBreakMode = .byTruncatingTail
        self.descriptionLabel = UILabel()
        self.descriptionLabel.numberOfLines = 0
        self.createdAt = UILabel()
        self.createdAt.translatesAutoresizingMaskIntoConstraints = false
        self.modifiedAt = UILabel()
        self.modifiedAt.translatesAutoresizingMaskIntoConstraints = false
        
        self.listItemSource = source
        self.listIndex = listIndex
        self.itemIndex = itemIndex
        let item = source.item(inList: listIndex, index: itemIndex)
        
        self.itemTitle.textBond.bind(item.name)
        self.url.textBond.bind(item.url)
        self.createdAt.text = item.createdAt.timeAgoSinceDate(numericDates: true)
        self.modifiedAt.friendlyDateStringBond.bind(item.modifiedAt)
        self.imageView.imageBond.bind(item.image)
        self.descriptionLabel.textBond.bind(item.description)
        
        let stackedViews : [UIView] = [self.itemTitle, self.imageView, self.url, self.descriptionLabel, self.createdAt, self.modifiedAt]
        
        super.init(frame: CGRect.zero)
        for view in stackedViews {
            self.addArrangedSubview(view)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.axis = .vertical
        self.distribution = .fill
        self.alignment = .fill
        self.spacing = 10
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 20.0).isActive = true
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 20.0).isActive = true
        
        self.backgroundColor = UIColor.white
    }
    required init(coder: NSCoder) {
        fatalError()
    }
}


