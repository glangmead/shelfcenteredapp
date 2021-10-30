//
//  SCEditItemViewController.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

class SCEditItemViewController : UIViewController, UITextFieldDelegate, UITextViewDelegate {
    var navCoordinator : SCNavigationCoordinator? = nil
    let listItemSource : SCListItemSource
    let listIndex : Int
    let itemIndex : Int
    let item : SCItemViewModel
    let itemView : SCEditItemView
    
    init(source: SCListItemSource, listIndex: Int, itemIndex: Int) {
        self.listItemSource = source
        self.listIndex = listIndex
        self.itemIndex = itemIndex
        self.item = source.item(inList: listIndex, index: itemIndex)
        self.itemView = SCEditItemView(item: item)
        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = []
        self.titleBond.bind(item.name)
        self.itemView.setTextDelegates(textFieldDelegate: self, textViewDelegate: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    override func loadView() {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.addSubview(itemView)
        scrollView.contentSize = itemView.frame.size
        self.view = scrollView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        item.description.value = textView.text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let newText = textField.text {
            if (itemView.textFieldIsTitle(field: textField)) {
                item.name.value = newText
            }
            if (itemView.textFieldIsURL(field: textField)) {
                item.url.value = newText
            }
        }
    }
}


