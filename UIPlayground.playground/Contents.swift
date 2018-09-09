import Foundation
import UIKit
import PlaygroundSupport
import CoreMotion

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

let reuseIdentifier = "ItemCell"
let listCellReuseIdentifier = "ListCell"

struct SCListViewModel {
    let name : String
    let user: String
}

struct SCItemViewModel {
    let name: String
    let image: UIImage?
    let url: String
    let createdAt: String
    let modifiedAt: String
    let claimed: Bool
    let editable: Bool
}

struct SCUserViewModel {
    let name: String
}

struct SCCommentViewModel {
    let comment: String
    let createdAt: String
    let modifiedAt: String
}

class SCItemCell : BaseRoundedCardCell {
    var imageView : UIImageView
    var title : UILabel
    var url : UILabel
    var createdAt : UILabel
    var modifiedAt : UILabel
    
    override init(frame: CGRect) {
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height*2/3))
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        let textInset : CGFloat = 5.0
        let textWidth = (frame.size.width - 2.0 * textInset)
        
        self.title = UILabel(frame: CGRect(x: textInset, y: imageView.frame.size.height, width: textWidth, height: frame.size.height/3))
        self.title.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        self.title.textAlignment = .left
        self.title.preferredMaxLayoutWidth = textWidth
        self.title.numberOfLines = 0 // activates multiline
        
        self.url = UILabel()
        self.createdAt = UILabel()
        self.modifiedAt = UILabel()
        

        super.init(frame: frame)
        
        self.contentView.backgroundColor = UIColor.lightGray
        contentView.addSubview(self.imageView)
        contentView.addSubview(self.title)
        
        contentView.layer.cornerRadius = 14
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func updateWithItem(newItem : SCItemViewModel) {
        imageView.image = newItem.image
        title.text = newItem.name
        url.text = newItem.url
        createdAt.text = newItem.createdAt
        modifiedAt.text = newItem.modifiedAt
        setNeedsDisplay()
    }
}

class SCItemView : UIView {
    let imageView : UIImageView
    let itemTitle : UILabel
    let url : UILabel
    let createdAt : UILabel
    let modifiedAt : UILabel
    let item : SCItemViewModel
    
    init(item : SCItemViewModel) {
        self.item = item
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
        self.createdAt = UILabel()
        self.createdAt.translatesAutoresizingMaskIntoConstraints = false
        self.modifiedAt = UILabel()
        self.modifiedAt.translatesAutoresizingMaskIntoConstraints = false
        
        self.url.text = item.url
        self.imageView.image = item.image
        self.itemTitle.text = item.name
        self.createdAt.text = item.createdAt
        self.modifiedAt.text = item.modifiedAt
        
        super.init(frame: CGRect.zero)

        self.addSubview(imageView)
        self.addSubview(itemTitle)
        self.addSubview(url)
        self.addSubview(createdAt)
        self.addSubview(modifiedAt)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func layoutSubviews() {
        self.frame = (self.superview?.bounds)!
    }
    
    func setupConstraints() {
        let margins = self.layoutMarginsGuide
        
        let textViews = [self.itemTitle, self.url, self.createdAt, self.modifiedAt]
        for textView in textViews {
            textView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
            textView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        }
        
        self.itemTitle.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true

        self.imageView.topAnchor.constraint(equalToSystemSpacingBelow: self.itemTitle.bottomAnchor, multiplier: 1).isActive = true
        self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        self.url.topAnchor.constraint(equalToSystemSpacingBelow: self.imageView.bottomAnchor, multiplier: 1).isActive = true
        
        self.createdAt.topAnchor.constraint(equalToSystemSpacingBelow: self.url.bottomAnchor, multiplier: 1).isActive = true
        
        self.modifiedAt.topAnchor.constraint(equalToSystemSpacingBelow: self.createdAt.bottomAnchor, multiplier: 1).isActive = true
        
    }
    
}

class SCItemViewController : UIViewController {
    let item : SCItemViewModel
    
    init(item : SCItemViewModel) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = []
        self.title = item.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func loadView() {
        let theView = SCItemView(item: self.item)
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.addSubview(theView)
        scrollView.contentSize = theView.frame.size
        scrollView.layer.borderColor = UIColor.red.cgColor
        theView.layer.borderColor = UIColor.blue.cgColor
        self.view = scrollView
    }
}

class SCListsViewController : UITableViewController {
    let listItemSource : SCListItemSource
    var navCoordinator : SCNavigationCoordinator? = nil
    
    init(listItemSource: SCListItemSource) {
        self.listItemSource = listItemSource
        super.init(style: .plain)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
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
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: listCellReuseIdentifier)
        }
        let list = listItemSource.list(index: indexPath.row)
        cell!.textLabel!.text = list.name
        cell!.detailTextLabel!.text = list.user
        cell!.accessoryType = .disclosureIndicator
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navCoordinator!.listSelected(source: self.listItemSource, listIndex: indexPath.row, fromVC: self)
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
        self.title = listItemSource.list(index: listIndex).name
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
        navC.pushViewController(SCItemViewController(item: source.item(inList: listIndex, index: itemIndex)), animated: true)
    }
    func listSelected(source: SCListItemSource, listIndex: Int, fromVC: UIViewController) {
        navC.pushViewController(SCListViewController(listItemSource: source, listIndex: listIndex, navCoordinator: self), animated: true)
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
    // delete
    func deleteList(index: Int)
    func deleteItem(inList: Int, index: Int)
}

class ArrayListItemSource : SCListItemSource {
    var lists : [SCListViewModel]
    var listItems : [[SCItemViewModel]]
    init(lists: [SCListViewModel], listItems: [[SCItemViewModel]]) {
        self.lists = lists
        self.listItems = listItems
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
    // delete
    func deleteList(index: Int) {
        self.lists.remove(at: index)
    }
    func deleteItem(inList: Int, index: Int) {
        self.listItems[inList].remove(at: index)
    }
}

let suckerPunchItem = SCItemViewModel(name: "Sucker Punch, an item I've always wanted but never bought", image: UIImage(named: "suckerPunch.jpg"), url: "https://smile.amazon.com/Sucker-Gimmicks-Online-Instructions-Southworth/dp/B01N4GYHMQ/ref=sr_1_10?ie=UTF8&qid=1518628995&sr=8-10&keywords=sucker+punch", createdAt: "today", modifiedAt: "today", claimed: false, editable: true)
let redFamineItem = SCItemViewModel(name: "Red Famine book", image: UIImage(named:"redFamineBook.jpg"), url: "", createdAt: "today", modifiedAt: "today", claimed: false, editable: true)
let bpItem = SCItemViewModel(name: "Black Panther", image: UIImage(named:"blackPantherBook.jpg"), url: "", createdAt: "today", modifiedAt: "today", claimed: false, editable: true)
let deskItem = SCItemViewModel(name: "Tummy desk", image: UIImage(named:"tummyDesk.jpg"), url: "", createdAt: "today", modifiedAt: "today", claimed: false, editable: true)

let laboItem = SCItemViewModel(name: "Labo", image: UIImage(named:"labo.jpg"), url: "", createdAt: "today", modifiedAt: "today", claimed: false, editable: true)
let iceItem = SCItemViewModel(name: "Ice maker", image: UIImage(named:"ice.jpg"), url: "", createdAt: "today", modifiedAt: "today", claimed: false, editable: true)
let penItem = SCItemViewModel(name: "Pen", image: UIImage(named:"pen.jpg"), url: "", createdAt: "today", modifiedAt: "today", claimed: false, editable: true)


func getTestSharedItemSource() -> SCListItemSource {
    let shelfItemSource = ArrayListItemSource(
        lists: [SCListViewModel(name: "Birthday 2018", user: "Mom"), SCListViewModel(name: "Christmas 2017", user: "Mom")],
        listItems: [[suckerPunchItem, redFamineItem], [bpItem, deskItem]]
    )
    return shelfItemSource
}

func getTestMyItemSource() -> SCListItemSource {
    let shelfItemSource = ArrayListItemSource(
        lists: [SCListViewModel(name: "My Birthday 2018", user: "Me"), SCListViewModel(name: "My Christmas 2017", user: "Me")],
        listItems: [[laboItem, iceItem], [penItem]]
    )
    return shelfItemSource
}

let vc = SCMainViewController(myDataSource: getTestMyItemSource(), sharedDataSource: getTestSharedItemSource())
PlaygroundPage.current.liveView = vc


