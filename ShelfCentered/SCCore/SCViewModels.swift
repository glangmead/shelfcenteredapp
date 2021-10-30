//
//  SCViewModels.swift
//  ShelfCentered
//
//  Created by Greg Langmead on 10/6/18.
//  Copyright © 2018 Greg Langmead. All rights reserved.
//

import UIKit
import CloudKit

public struct SCListViewModel {
    var name : Dynamic<String> = Dynamic<String>("")
    var description : Dynamic<String> = Dynamic<String>("")
    var user: Dynamic<String> = Dynamic<String>("")
    var createdAt: Date = Date()
    var modifiedAt: Dynamic<Date> = Dynamic<Date>(Date())
    var deleted: Bool = false

    init(name : String, description: String, user : String, createdAt : Date, modifiedAt : Date) {
        self.name.value = name
        self.description.value = description
        self.user.value = user
        self.createdAt = createdAt
        self.modifiedAt.value = modifiedAt
    }
    init() {
        self.init(name: "", description: "", user: "", createdAt: Date(), modifiedAt: Date())
    }
}

public struct SCItemViewModel {
    var name: Dynamic<String> = Dynamic<String>("")
    var image: Dynamic<UIImage?> = Dynamic<UIImage?>(nil)
    var url: Dynamic<String> = Dynamic<String>("")
    var description: Dynamic<String> = Dynamic<String>("")
    var createdAt: Date = Date()
    var modifiedAt: Dynamic<Date> = Dynamic<Date>(Date())
    var claimed: Dynamic<Bool> = Dynamic<Bool>(false)
    var editable: Bool = false
    var deleted: Bool = false

    init(name: String, image: UIImage?, url: String, description: String, createdAt: Date, modifiedAt: Date, claimed: Bool, editable: Bool) {
        self.name.value = name
        self.image.value = image
        self.url.value = url
        self.description.value = description
        self.createdAt = createdAt
        self.modifiedAt.value = modifiedAt
        self.claimed.value = claimed
        self.editable = editable
    }
    init(name: String, image: UIImage?, url: String, description: String) {
        self.init(name: name, image: image, url: url, description: description, createdAt: Date(), modifiedAt: Date(), claimed: false, editable: true)
    }
    init() {
        self.init(name: "", image: nil, url: "", description: "")
    }
}

public struct SCUserViewModel {
    var name: Dynamic<String>
}

public struct SCCommentViewModel {
    var comment: Dynamic<String> = Dynamic<String>("")
    var user: Dynamic<String> = Dynamic<String>("")
    var createdAt: Date = Date()
    var modifiedAt: Dynamic<Date> = Dynamic<Date>(Date())
    var editable: Bool
    var deleted: Bool = false

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

