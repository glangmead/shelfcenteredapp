//
//  SCEditItemView.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

class SCEditItemView : UIView {
    let imageView : UIImageView
    let itemTitleLabel : UILabel
    let itemTitle : UITextField
    let url : UITextField
    let urlLabel : UILabel
    let descriptionView : UITextView
    let descriptionLabel : UILabel
    let item : SCItemViewModel
    
    func textFieldIsTitle(field : UITextField) -> Bool {
        return field == itemTitle
    }
    
    func textFieldIsURL(field : UITextField) -> Bool {
        return field == url
    }
    
    func textFieldIsDescription(field : UITextField) -> Bool {
        return field == descriptionView
    }
    
    func setTextDelegates(textFieldDelegate : UITextFieldDelegate, textViewDelegate : UITextViewDelegate) {
        self.itemTitle.delegate = textFieldDelegate
        self.url.delegate = textFieldDelegate
        self.descriptionView.delegate = textViewDelegate
    }
    
    init(item : SCItemViewModel) {
        self.item = item
        self.imageView = UIImageView()
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.itemTitle = UITextField()
        self.itemTitle.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        self.itemTitle.translatesAutoresizingMaskIntoConstraints = false
        self.url = UITextField()
        self.url.translatesAutoresizingMaskIntoConstraints = false
        self.itemTitleLabel = UILabel()
        self.itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.urlLabel = UILabel()
        self.urlLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel = UILabel()
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionView = UITextView()
        self.descriptionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.url.text = item.url.value
        self.imageView.imageBond.bind(item.image)
        self.itemTitle.text = item.name.value
        self.descriptionView.text = item.description.value
        self.itemTitleLabel.text = "Title"
        self.urlLabel.text = "URL"
        self.descriptionLabel.text = "Comment"
        
        super.init(frame: CGRect.zero)
        
        let stackView = UIStackView(arrangedSubviews: [itemTitleLabel, itemTitle, imageView, urlLabel, url, descriptionLabel, descriptionView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func layoutSubviews() {
        self.frame = (self.superview?.bounds)!
    }
}


