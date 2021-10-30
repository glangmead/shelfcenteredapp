//
//  SCCommentsViewController.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

class SCCommentsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    let listItemSource : SCListItemSource
    let listIndex : Int
    let itemIndex : Int
    let cellReuseID : String = "CommentCell"
    let tableView : UITableView
    let newCommentView : UITextView
    let newCommentHint = "Type your comment"
    init(source: SCListItemSource, listIndex : Int, itemIndex : Int) {
        self.listItemSource = source
        self.listIndex = listIndex
        self.itemIndex = itemIndex
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.newCommentView = UITextView(frame: CGRect.zero)
        self.newCommentView.text = newCommentHint
        super.init(nibName: nil, bundle: nil)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.newCommentView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellReuseID)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.newCommentView.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    override func loadView() {
        let stack = UIStackView(arrangedSubviews: [self.tableView, self.newCommentView])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 10
        self.view = stack
        let numComments = self.listItemSource.numberOfComments(inList: self.listIndex, index: self.itemIndex)
        self.tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: (40 * CGFloat(numComments))).isActive = true
        self.newCommentView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        self.newCommentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == newCommentHint {
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.listItemSource.addItemComment(inList: self.listIndex, index: self.itemIndex, comment: SCCommentViewModel(comment: textView.text, user: "???", editable: true))
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numComments = self.listItemSource.numberOfComments(inList: listIndex, index: itemIndex)
        return numComments
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: self.cellReuseID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.cellReuseID)
        }
        let comment = listItemSource.comment(inList: listIndex, index: itemIndex, commentIndex: indexPath.row)
        cell!.textLabel?.textBond.bind(comment.comment)
        cell!.textLabel?.numberOfLines = 0
        cell!.detailTextLabel?.text = "This is the way the subtitle trots."
        //    cell!.detailTextLabel!.nameAndDateBondWithDate(comment.modifiedAt.value).bind(comment.user)
        //    cell!.detailTextLabel!.nameAndDateBondWithName(comment.user.value).bind(comment.modifiedAt)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


