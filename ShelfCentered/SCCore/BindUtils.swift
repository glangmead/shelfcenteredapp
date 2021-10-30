//
//  BindUtils.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit

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
        return Bond<UIImage?>() { [unowned self] newImg in self.image = newImg}
    }
}

func printViewHierarchy(vc: UIViewController) {
    printViewHierarchy(vc.view)
}

func printViewHierarchy(_ view: UIView, indent: String = "") {
    print("\(indent)\(view)")
    for subview in view.subviews {
        printViewHierarchy(subview, indent: indent + "  ")
    }
}

