//
//  SCItemViewController.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

class SCItemViewController : UIViewController, UITextViewDelegate {
    var navCoordinator : SCNavigationCoordinator? = nil
    let listItemSource : SCListItemSource
    let listIndex : Int
    let itemIndex : Int
    let item : SCItemViewModel
    let commentsVC : SCCommentsViewController
    let scrollView : UIScrollView
    let stackView : UIStackView
    let itemView : SCItemView
    
    init(source: SCListItemSource, listIndex: Int, itemIndex: Int) {
        self.listItemSource = source
        self.listIndex = listIndex
        self.itemIndex = itemIndex
        self.item = source.item(inList: listIndex, index: itemIndex)
        
        self.scrollView = UIScrollView(frame: CGRect.zero)
        
        self.commentsVC = SCCommentsViewController(source: source, listIndex: listIndex, itemIndex: itemIndex)
        self.itemView = SCItemView(source: listItemSource, listIndex: listIndex, itemIndex: itemIndex)
        
        self.stackView = UIStackView(arrangedSubviews: [self.itemView, self.commentsVC.view!])
        
        self.stackView.axis = .vertical
        self.stackView.distribution = .fill
        self.stackView.alignment = .fill
        self.stackView.spacing = 10
        self.scrollView.addSubview(self.stackView)
        super.init(nibName: nil, bundle: nil)
        self.titleBond.bind(item.name)
        
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        
        if (self.item.editable) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        }
    }
    
    @objc func editButtonPressed() {
        navCoordinator?.itemEditing(source: listItemSource, listIndex: listIndex, itemIndex: itemIndex, fromVC: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        listItemSource.addItemComment(inList: listIndex, index: itemIndex, comment: SCCommentViewModel(comment: textView.text, user: "???", editable: true))
    }
    
    override func viewWillLayoutSubviews() {
        for view in [self.stackView] {
            view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        }
        for view in [self.itemView, self.commentsVC.view] {
            view?.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 1.0).isActive = true
        }
    }
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.stackView.frame.size.height)
    }
    
    override func loadView() {
        self.view = scrollView
        self.view.backgroundColor = UIColor.white
    }
}


