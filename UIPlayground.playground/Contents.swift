import Foundation
import UIKit
import PlaygroundSupport
import CoreMotion
import ObjectiveC

func printViewHierarchy(vc: UIViewController) {
    printViewHierarchy(vc.view)
}

func printViewHierarchy(_ view: UIView, indent: String = "") {
    print("\(indent)\(view)")
    for subview in view.subviews {
        printViewHierarchy(subview, indent: indent + "  ")
    }
}

extension Date {
    func timeAgoSinceDate(numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest =  self > now ? self : now
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfMonth, .month, .year, .second]
        let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)
        if let year = components.year {
            if (year >= 2) {
                return "\(year) years ago"
            } else if (year >= 1) {
                return stringToReturn(flag: numericDates, strings: ("1 year ago", "Last year"))
            }
        }
        if let month = components.month {
            if (month >= 2) {
                return "\(month) months ago"
            } else if (month >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 month ago", "Last month"))
            }
        }
        if let weekOfYear = components.weekOfYear {
            if (weekOfYear >= 2) {
                return "\(weekOfYear) months ago"
            } else if (weekOfYear >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 week ago", "Last week"))
            }
        }
        if let day = components.day {
            if (day >= 2) {
                return "\(day) days ago"
            } else if (day >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 day ago", "Yesterday"))
            }
        }
        if let hour = components.hour {
            if (hour >= 2) {
                return "\(hour) hours ago"
            } else if (hour >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 hour ago", "An hour ago"))
            }
        }
        if let minute = components.minute {
            if (minute >= 2) {
                return "\(minute) minutes ago"
            } else if (minute >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 minute ago", "A minute ago"))
            }
        }
        if let second = components.second {
            if (second >= 3) {
                return "\(second) seconds ago"
            }
        }
        return "Just now"
    }
    
    private func stringToReturn(flag:Bool, strings: (String, String)) -> String {
        if (flag){
            return strings.0
        } else {
            return strings.1
        }
    }
}

internal class BaseRoundedCardCell: UICollectionViewCell {
    
    internal static let cellHeight: CGFloat = 470.0
    
    private static let kInnerMargin: CGFloat = 20.0
    
    /// Core Motion Manager
    private let motionManager = CMMotionManager()
    
    /// Long Press Gesture Recognizer
    private var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil
    
    /// Is Pressed State
    private var isPressed: Bool = false
    
    /// Shadow View
    private weak var shadowView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureGestureRecognizer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureShadow()
    }
    
    // MARK: - Shadow
    
    private func configureShadow() {
        // Shadow View
        self.shadowView?.removeFromSuperview()
        let shadowView = UIView(frame: CGRect(x: BaseRoundedCardCell.kInnerMargin,
                                              y: BaseRoundedCardCell.kInnerMargin,
                                              width: bounds.width - (2 * BaseRoundedCardCell.kInnerMargin),
                                              height: bounds.height - (2 * BaseRoundedCardCell.kInnerMargin)))
        insertSubview(shadowView, at: 0)
        self.shadowView = shadowView
        
        // Roll/Pitch Dynamic Shadow
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
                if let motion = motion {
                    let pitch = motion.attitude.pitch * 10 // x-axis
                    let roll = motion.attitude.roll * 10 // y-axis
                    self.applyShadow(width: CGFloat(roll), height: CGFloat(pitch))
                }
            })
        }
    }
    
    private func applyShadow(width: CGFloat, height: CGFloat) {
        if let shadowView = shadowView {
            let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 14.0)
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowRadius = 8.0
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize(width: width, height: height)
            shadowView.layer.shadowOpacity = 0.35
            shadowView.layer.shadowPath = shadowPath.cgPath
        }
    }
    
    // MARK: - Gesture Recognizer
    
    private func configureGestureRecognizer() {
        // Long Press Gesture Recognizer
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gestureRecognizer:)))
        longPressGestureRecognizer?.minimumPressDuration = 0.1
        addGestureRecognizer(longPressGestureRecognizer!)
    }
    
    @objc internal func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            handleLongPressBegan()
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            handleLongPressEnded()
        }
    }
    
    private func handleLongPressBegan() {
        guard !isPressed else {
            return
        }
        
        isPressed = true
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
    }
    
    private func handleLongPressEnded() {
        guard isPressed else {
            return
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform.identity
        }) { (finished) in
            self.isPressed = false
        }
    }
    
}


typealias Listener<T> = (T) -> Void

class Dynamic<T> {
    var value: T {
        didSet {
            for bondBox in bonds {
                bondBox.bond?.listener(value)
            }
        }
    }
    
    var bonds: [BondBox<T>] = []

    init(_ v: T) {
        value = v
    }
}

class BondBox<T> {
    weak var bond: Bond<T>?
    init(_ b: Bond<T>) { bond = b }
}

class Bond<T> {
    var listener: Listener<T>
    
    init(_ listener: @escaping Listener<T>) {
        self.listener = listener
    }
    
    func bind(_ dynamic: Dynamic<T>) {
        dynamic.bonds.append(BondBox(self))
        listener(dynamic.value)
    }
}

private var handle: UInt8 = 0;

extension UILabel {
    var textBond: Bond<String> {
        if let b: Any = objc_getAssociatedObject(self, &handle) {
            return b as! Bond<String>
        } else {
            let b = Bond<String>() { [unowned self] v in self.text = v }
            objc_setAssociatedObject(self, &handle, b, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return b
        }
    }
    var nameAndDateBondWithName: (_ name : String) -> Bond<Date> {
        return { name in
            if let b: Any = objc_getAssociatedObject(self, &handle) {
                return b as! Bond<Date>
            } else {
                let b = Bond<Date>() { [unowned self] d in self.text = "by \(name), \(d.timeAgoSinceDate(numericDates: true))" }
                objc_setAssociatedObject(self, &handle, b, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return b
            }
        }
    }
    var nameAndDateBondWithDate: (_ date : Date) -> Bond<String> {
        return { date in
            if let b: Any = objc_getAssociatedObject(self, &handle) {
                return b as! Bond<String>
            } else {
                let b = Bond<String>() { [unowned self] name in self.text = "by \(name), \(date.timeAgoSinceDate(numericDates: true))" }
                objc_setAssociatedObject(self, &handle, b, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return b
            }
        }
    }
    var friendlyDateStringBond: Bond<Date> {
        if let b: Any = objc_getAssociatedObject(self, &handle) {
            return b as! Bond<Date>
        } else {
            let b = Bond<Date>() { [unowned self] d in self.text = d.timeAgoSinceDate(numericDates: true) }
            objc_setAssociatedObject(self, &handle, b, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return b
        }
    }
}

extension UIViewController {
    var titleBond : Bond<String> {
        return Bond<String>() { [unowned self] newTitle in self.title = newTitle }
    }
}

extension UIImageView {
    var imageBond : Bond<UIImage?> {
        return Bond<UIImage?>() { [unowned self] newImg in self.image = newImg!}
    }
}

let reuseIdentifier = "ItemCell"
let listCellReuseIdentifier = "ListCell"
let editItemCellIdentifier = "EditCell"

struct SCListViewModel {
    var name : Dynamic<String> = Dynamic<String>("")
    var user: Dynamic<String> = Dynamic<String>("")
    var createdAt: Date = Date()
    var modifiedAt: Dynamic<Date> = Dynamic<Date>(Date())
    init(name : String, user : String, createdAt : Date, modifiedAt : Date) {
        self.name.value = name
        self.user.value = user
        self.createdAt = createdAt
        self.modifiedAt.value = modifiedAt
    }
    init() {
        self.init(name: "", user: "", createdAt: Date(), modifiedAt: Date())
    }
}

struct SCItemViewModel {
    var name: Dynamic<String> = Dynamic<String>("")
    var image: Dynamic<UIImage?> = Dynamic<UIImage?>(nil)
    var url: Dynamic<String> = Dynamic<String>("")
    var description: Dynamic<String> = Dynamic<String>("")
    var comments: [SCCommentViewModel]
    var createdAt: Date = Date()
    var modifiedAt: Dynamic<Date> = Dynamic<Date>(Date())
    var claimed: Dynamic<Bool> = Dynamic<Bool>(false)
    var editable: Bool = false
    
    init(name: String, image: UIImage?, url: String, description: String, comments: [SCCommentViewModel], createdAt: Date, modifiedAt: Date, claimed: Bool, editable: Bool) {
        self.name.value = name
        self.image.value = image
        self.url.value = url
        self.description.value = description
        self.comments = comments
        self.createdAt = createdAt
        self.modifiedAt.value = modifiedAt
        self.claimed.value = claimed
        self.editable = editable
    }
    init(name: String, image: UIImage?, url: String, description: String) {
        self.init(name: name, image: image, url: url, description: description, comments: [], createdAt: Date(), modifiedAt: Date(), claimed: false, editable: true)
    }
}

struct SCUserViewModel {
    var name: Dynamic<String>
}

struct SCCommentViewModel {
    var comment: Dynamic<String> = Dynamic<String>("")
    var user: Dynamic<String> = Dynamic<String>("")
    var createdAt: Date = Date()
    var modifiedAt: Dynamic<Date> = Dynamic<Date>(Date())
    var editable: Bool
    
    init(comment: String, user: String, createdAt: Date, modifiedAt: Date, editable: Bool) {
        self.comment.value = comment
        self.user.value = user
        self.createdAt = createdAt
        self.modifiedAt.value = modifiedAt
        self.editable = editable
    }
    init(comment: String, user: String, editable: Bool) {
        self.init(comment: comment, user: user, createdAt: Date(), modifiedAt: Date(), editable: true)
    }
}

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
        let numComments = self.listItemSource.item(inList: self.listIndex, index: self.itemIndex).comments.count
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
        let numComments = self.listItemSource.item(inList: listIndex, index: itemIndex).comments.count
        return numComments
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: self.cellReuseID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.cellReuseID)
        }
        let comment = listItemSource.item(inList: listIndex, index: itemIndex).comments[indexPath.row]
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

class SCListsViewController : UITableViewController {
    let listItemSource : SCListItemSource
    var navCoordinator : SCNavigationCoordinator? = nil
    
    init(listItemSource: SCListItemSource) {
        self.listItemSource = listItemSource
        super.init(style: .plain)
        if (!self.listItemSource.readOnly()) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    @objc func addButtonPressed() {
        listItemSource.addList(list: SCListViewModel(name: "New List \(listItemSource.numberOfLists() + 1)", user: "Me", createdAt: Date(), modifiedAt: Date()))
        self.tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItemSource.numberOfLists()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: listCellReuseIdentifier)
        if (cell == nil) {
            cell = SCListCell(style: .subtitle, reuseIdentifier: listCellReuseIdentifier)
        }
        let list = listItemSource.list(index: indexPath.row)
        (cell as! SCListCell).list = list
        return cell!
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navCoordinator!.listSelected(source: self.listItemSource, listIndex: indexPath.row, fromVC: self)
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !listItemSource.readOnly()
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
            self.listItemSource.deleteList(index: indexPath.row)
            tableView.reloadData()
            }
        return [deleteAction]
    }
}

class SCListViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let listItemSource : SCListItemSource
    let listIndex : Int
    let navCoordinator : SCNavigationCoordinator

    init(listItemSource: SCListItemSource, listIndex : Int, navCoordinator : SCNavigationCoordinator) {
        self.listItemSource = listItemSource
        self.listIndex = listIndex
        self.navCoordinator = navCoordinator
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.titleBond.bind(listItemSource.list(index: listIndex).name)
        if (!self.listItemSource.readOnly()) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(SCItemCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
    }
    @objc func addButtonPressed() {
        listItemSource.addItem(inList: self.listIndex, item: SCItemViewModel(name: "Item \(self.listItemSource.numberOfItems(inList: self.listIndex) + 1)", image: nil, url: "", description: ""))
        self.listItemSource.sortByModifiedLatestFirst()
        self.collectionView.reloadData()
    }

    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navCoordinator.itemSelected(source: self.listItemSource, listIndex: self.listIndex, itemIndex: indexPath.row, fromVC: self)
    }

    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItemSource.numberOfItems(inList: listIndex)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SCItemCell
        cell.updateWithItem(newItem: listItemSource.item(inList: listIndex, index: indexPath.row))
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right), height: 470)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
}

// tabs are: shared lists, my lists, add item

class SCNewItemViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red
    }
}

class SCNewListViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.green
    }
}

struct SCNavigationCoordinator {
    let navC : UINavigationController
    func itemSelected(source: SCListItemSource, listIndex: Int, itemIndex: Int, fromVC: UIViewController) {
        let itemVC = SCItemViewController(source: source, listIndex: listIndex, itemIndex: itemIndex)
        itemVC.navCoordinator = self
        navC.pushViewController(itemVC, animated: true)
    }
    func listSelected(source: SCListItemSource, listIndex: Int, fromVC: UIViewController) {
        navC.pushViewController(SCListViewController(listItemSource: source, listIndex: listIndex, navCoordinator: self), animated: true)
    }
    func itemEditing(source: SCListItemSource, listIndex: Int, itemIndex: Int, fromVC: UIViewController) {
        navC.pushViewController(SCEditItemViewController(source: source, listIndex: listIndex, itemIndex: itemIndex), animated: true)
    }
}

class SCMainViewController : UITabBarController {
    
    let myDataSource : SCListItemSource
    let sharedDataSource : SCListItemSource
    
    init(myDataSource : SCListItemSource, sharedDataSource : SCListItemSource) {
        self.myDataSource = myDataSource
        self.sharedDataSource = sharedDataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("can't init with coder")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orange
        
        let sharedListsVC = SCListsViewController(listItemSource: sharedDataSource)
        let sharedListsNavC = UINavigationController(rootViewController: sharedListsVC)
        let sharedListsCoordinator = SCNavigationCoordinator(navC: sharedListsNavC)
        sharedListsVC.navCoordinator = sharedListsCoordinator
        sharedListsVC.title = "Shared Lists"
        sharedListsNavC.tabBarItem = UITabBarItem(title: "Shared Lists", image: UIImage(named: "cloud"), tag: 0)

        let myListsVC = SCListsViewController(listItemSource: myDataSource)
        let myListsNavC = UINavigationController(rootViewController: myListsVC)
        let myListsCoordinator = SCNavigationCoordinator(navC: myListsNavC)
        myListsVC.navCoordinator = myListsCoordinator
        myListsVC.title = "My Lists"
        myListsNavC.tabBarItem = UITabBarItem(title: "My Lists", image: UIImage(named: "list"), tag: 1)

        viewControllers = [sharedListsNavC, myListsNavC]
    }
}

protocol SCListItemSource {
    func userIsMe(user: String) -> Bool
    func readOnly() -> Bool
    // create
    func addList(list: SCListViewModel)
    func addItem(inList: Int, item: SCItemViewModel)
    // read
    func numberOfLists() -> Int
    func list(index : Int) -> SCListViewModel
    func numberOfItems(inList: Int) -> Int
    func item(inList: Int, index: Int) -> SCItemViewModel
    // update
    func updateList(index: Int, newData: SCListViewModel)
    func updateItem(inList: Int, index: Int, newData: SCItemViewModel)
    func deleteItemComment(inList: Int, index: Int, commentIndex: Int)
    func addItemComment(inList: Int, index: Int, comment: SCCommentViewModel)
    // delete
    func deleteList(index: Int)
    func deleteItem(inList: Int, index: Int)
    // sort
    func sortByModifiedLatestFirst()
}

class ArrayListItemSource : SCListItemSource, CustomStringConvertible {
    func userIsMe(user: String) -> Bool {
        return user == "Greg"
    }
    var lists : [SCListViewModel]
    var listItems : [[SCItemViewModel]]
    let isReadOnly : Bool
    init(lists: [SCListViewModel], listItems: [[SCItemViewModel]], readOnly: Bool) {
        self.lists = lists
        self.listItems = listItems
        self.isReadOnly = readOnly
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
    // update
    func updateList(index: Int, newData: SCListViewModel) {
        self.lists[index] = newData
    }
    func updateItem(inList: Int, index: Int, newData: SCItemViewModel) {
        self.listItems[inList][index] = newData
    }
    func deleteItemComment(inList: Int, index: Int, commentIndex: Int) {
        listItems[inList][index].comments.remove(at: commentIndex)
    }
    func addItemComment(inList: Int, index: Int, comment: SCCommentViewModel) {
        listItems[inList][index].comments.append(comment)
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
}

let suckerPunchItem = SCItemViewModel(name: "Sucker Punch, an item I've always wanted but never bought", image: UIImage(named: "suckerPunch.jpg"), url: "https://smile.amazon.com/Sucker-Gimmicks-Online-Instructions-Southworth/dp/B01N4GYHMQ/ref=sr_1_10?ie=UTF8&qid=1518628995&sr=8-10&keywords=sucker+punch", description: "", comments: [], createdAt: Date(), modifiedAt: Date(), claimed: false, editable: false)
let redFamineItem = SCItemViewModel(name: "Red Famine book", image: UIImage(named:"redFamineBook.jpg"), url: "", description: "", comments: [], createdAt: Date(), modifiedAt: Date(), claimed: false, editable: false)
let bpItem = SCItemViewModel(name: "Black Panther", image: UIImage(named:"blackPantherBook.jpg"), url: "", description: "", comments: [], createdAt: Date(), modifiedAt: Date(), claimed: false, editable: false)
let deskItem = SCItemViewModel(name: "Tummy desk", image: UIImage(named:"tummyDesk.jpg"), url: "", description: "", comments: [], createdAt: Date(), modifiedAt: Date(), claimed: false, editable: false)

var laboItem = SCItemViewModel(name: "Labo", image: UIImage(named:"labo.jpg"), url: "", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit vitae velit sed mollis. Pellentesque sodales consequat urna quis fermentum. Donec arcu urna, suscipit quis fringilla a, venenatis non lectus. Phasellus tristique nulla id sollicitudin auctor. Nunc tincidunt felis sed rutrum fermentum. Sed ullamcorper tincidunt nunc, eu pretium mauris ultricies blandit. Donec faucibus commodo leo, viverra auctor lacus egestas a.")
var laboComments = [
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
laboItem.comments = laboComments
let iceItem = SCItemViewModel(name: "Ice maker", image: UIImage(named:"ice.jpg"), url: "", description: "")
let penItem = SCItemViewModel(name: "Pen", image: UIImage(named:"pen.jpg"), url: "", description: "")


func getTestSharedItemSource() -> SCListItemSource {
    let shelfItemSource = ArrayListItemSource(
        lists: [SCListViewModel(name: "Birthday 2018", user: "Mom", createdAt: Date(), modifiedAt: Date()), SCListViewModel(name: "Christmas 2017", user: "Mom", createdAt: Date(), modifiedAt: Date())],
        listItems: [[suckerPunchItem, redFamineItem], [bpItem, deskItem]],
        readOnly: true
    )
    return shelfItemSource
}

func getTestMyItemSource() -> SCListItemSource {
    let shelfItemSource = ArrayListItemSource(
        lists: [SCListViewModel(name: "My Birthday 2018", user: "Me", createdAt: Date(), modifiedAt: Date()), SCListViewModel(name: "My Christmas 2017", user: "Me", createdAt: Date(), modifiedAt: Date())],
        listItems: [[laboItem, iceItem], [penItem]],
        readOnly: false
    )
    return shelfItemSource
}

let vc = SCMainViewController(myDataSource: getTestMyItemSource(), sharedDataSource: getTestSharedItemSource())
PlaygroundPage.current.liveView = vc

// UIApplication.shared.open(url, options: [:], completionHandler: nil)

//let slp = SwiftLinkPreview(session: URLSession.shared,
//                           workQueue: SwiftLinkPreview.defaultWorkQueue,
//                           responseQueue: DispatchQueue.main,
//                           cache: DisabledCache.instance)
//slp.preview("https://smile.amazon.com/ToiletTree-Professional-Resistant-Trimmer-Silver/dp/B00E4PMQAO/",
//            onSuccess: { result in print("\(result)") },
//            onError: { error in print("\(error)")})
