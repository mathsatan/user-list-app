//
//  UserContact.swift
//  UserListApp
//
//  Created by max kruchkov on 8/27/18.
//  Copyright © 2018 max kruchkov. All rights reserved.
//

import Foundation
import RealmSwift

class UserContact: Object {
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var phone: String = ""
    @objc dynamic var picUrl: String = ""
}
