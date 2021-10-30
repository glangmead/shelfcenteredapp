//
//  SCItemCell.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

class SCItemCell : BaseRoundedCardCell {
    var imageView : UIImageView
    var title : UILabel
    var url : UILabel
    var descriptionLabel: UILabel
    var modifiedAt : UILabel
    
    override init(frame: CGRect) {
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height*2/3))
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        self.title = UILabel()
        self.title.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        self.title.numberOfLines = 0 // activates multiline
        self.title.translatesAutoresizingMaskIntoConstraints = false
        
        self.descriptionLabel = UILabel()
        self.descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        self.descriptionLabel.numberOfLines = 5
        self.descriptionLabel.lineBreakMode = .byWordWrapping
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.url = UILabel()
        self.modifiedAt = UILabel()
        
        
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UIColor.lightGray
        let stackedView = UIStackView(arrangedSubviews: [self.imageView, self.title, self.descriptionLabel, self.url, self.modifiedAt])
        
        stackedView.axis = .vertical
        stackedView.distribution = .fill
        stackedView.alignment = .fill
        stackedView.spacing = 10
        stackedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackedView)
        stackedView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0).isActive = true
        
        contentView.layer.cornerRadius = 14
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWithItem(newItem : SCItemViewModel) {
        imageView.imageBond.bind(newItem.image)
        title.textBond.bind(newItem.name)
        descriptionLabel.textBond.bind(newItem.description)
        url.textBond.bind(newItem.url)
        modifiedAt.friendlyDateStringBond.bind(newItem.modifiedAt)
        setNeedsDisplay()
    }
}

