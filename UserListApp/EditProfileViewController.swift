//
//  EditProfileViewController.swift
//  UserListApp
//
//  Created by max kruchkov on 8/28/18.
//  Copyright © 2018 max kruchkov. All rights reserved.
//

import UIKit
import RealmSwift

class EditableTableViewCell: UITableViewCell {
    @IBOutlet weak var infoName: UILabel!
    @IBOutlet weak var infoValue: UITextField!
}

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var realm: Realm!
    
    var userContactList: Results<UserContact> {
        get {
            return realm.objects(UserContact.self)
        }
    }
    
    let infoCount = 4
    let userInfoLabels = ["First name", "Last name", "Email", "Phone"]
    
    @IBOutlet weak var tableUserInfo: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "info_cell", for: indexPath) as! EditableTableViewCell
        infoCell.infoName?.text = userInfoLabels[indexPath.row]
        infoCell.infoValue?.text = EditProfileViewController.getCurrentField(selectedContact, indexPath.row)
        
        return infoCell
    }
    
    private static func getCurrentField(_ user: UserContact, _ index: Int) -> String {
        switch index {
        case 0:
            return user.firstName
        case 1:
            return user.lastName
        case 2:
            return user.email
        case 3:
            return user.phone
        default:
            return ""
        }
    }

    @IBOutlet weak var profilePic: UIImageView!
    var selectedContact = UserContact()
    var tabIndex = 0
    
    @IBAction func backToMain(_ sender: UIBarButtonItem) {
        self.tabIndex = 0
        self.performSegue(withIdentifier: "from_edit_to_main", sender: self)
    }
    
    @IBAction func backToSaved(_ sender: UIBarButtonItem) {
        saveToStorage()
        self.tabIndex = 1
        self.performSegue(withIdentifier: "from_edit_to_main", sender: self)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        
        self.profilePic.layer.cornerRadius = profilePic.frame.size.width / 2.0
        self.profilePic.clipsToBounds = true
        
        if let picUrl = URL(string: selectedContact.picUrl) {
            UserListUtil.getDataFromUrl(url: picUrl) { data, response, error in
                guard let data = data, error == nil else { print("Error has occured: " + error.debugDescription); return }
                DispatchQueue.main.async() {
                    self.profilePic.image = UIImage(data: data)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabBarVC = segue.destination as? UserTabBarController {
            tabBarVC.tabIndex = self.tabIndex
        }
    }
    
    func saveToStorage() {
        if let item = userContactList.filter("userId = %@", selectedContact.userId).first {
            try! self.realm.write({
                if let cell = tableUserInfo.cellForRow(at: IndexPath(row: 0, section: 0)) as? EditableTableViewCell, let newFirstName = cell.infoValue?.text {
                    item.firstName = newFirstName
                }
                if let cell = tableUserInfo.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditableTableViewCell, let newLastName = cell.infoValue?.text {
                    item.lastName = newLastName
                }
                if let cell = tableUserInfo.cellForRow(at: IndexPath(row: 2, section: 0)) as? EditableTableViewCell, let newEmail = cell.infoValue?.text {
                    item.email = newEmail
                }
                if let cell = tableUserInfo.cellForRow(at: IndexPath(row: 3, section: 0)) as? EditableTableViewCell, let newPhone = cell.infoValue?.text {
                    item.phone = newPhone
                }
            })
        } else {
            try! self.realm.write({
                self.realm.add(selectedContact)
            })
        }
    }
}
