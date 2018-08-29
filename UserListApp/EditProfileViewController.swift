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
   
    var ownVC: EditProfileViewController?
    
    @IBAction func resignEdit(_ sender: UITextField) {
        
        if let table = self.superview as? UITableView, let row = table.indexPath(for: self)?.row {
            if row < 2 {
                if let newText = self.infoValue?.text {
                    if !InputValidator.name(newText) {
                        sender.layer.borderColor = UIColor.red.cgColor
                        sender.layer.borderWidth = 1
                        ownVC?.inputError = EditProfileViewController.InputError(message: "Name is incorrect", row: row)
                    }
                }
            }
        }
        
        sender.textColor = UIColor.gray
    }
    
    @IBAction func testEdit(_ sender: UITextField) {
        sender.layer.borderWidth = 0
        sender.layer.borderColor = UIColor.white.cgColor
        sender.textColor = UIColor.black
    }
}

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    struct InputError {
        let message: String
        let row: Int
    }
    var inputError: InputError?
    
    var realm: Realm!
    
    var userContactList: Results<UserContact> {
        get {
            return realm.objects(UserContact.self)
        }
    }
    
    @IBOutlet weak var profilePic: UIImageView!
    var selectedContact = UserContact()
    var tabIndex = 0
    let infoCount = 4
    let userInfoLabels = ["First name", "Last name", "Email", "Phone"]
    
    @IBOutlet weak var tableUserInfo: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "info_cell", for: indexPath) as! EditableTableViewCell
        infoCell.ownVC = self
        infoCell.infoName?.text = userInfoLabels[indexPath.row]
        infoCell.infoValue?.text = EditProfileViewController.getCurrentField(selectedContact, indexPath.row)
        
        return infoCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UserListUtil.rowHeight
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
    
    @IBAction func backToMain(_ sender: UIBarButtonItem) {
        self.tabIndex = 0
        self.performSegue(withIdentifier: "from_edit_to_main", sender: self)
    }
    
    @IBAction func backToSaved(_ sender: UIBarButtonItem) {
        var newFirstName: String = ""
        var newLastName: String = ""
        var newPhone: String = ""
        var newEmail: String = ""
        
        self.inputError = nil
        
        if let cell = tableUserInfo.cellForRow(at: IndexPath(row: 0, section: 0)) as? EditableTableViewCell, let fn = cell.infoValue?.text {
            if !InputValidator.name(fn) {
                self.inputError = InputError(message: "First name is incorrect!", row: 0)
            } else {
                newFirstName = fn
            }
        }
        if let cell = tableUserInfo.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditableTableViewCell, let ln = cell.infoValue?.text {
            if !InputValidator.name(ln) {
                self.inputError = InputError(message: "Last name is incorrect!", row: 1)
            } else {
                newLastName = ln
            }
        }
        
        if let cell = tableUserInfo.cellForRow(at: IndexPath(row: 2, section: 0)) as? EditableTableViewCell, let em = cell.infoValue?.text {
            if !InputValidator.email(em) {
                self.inputError = InputError(message: "Email is incorrect!", row: 2)
            } else {
                newEmail = em
            }
        }
        if let cell = tableUserInfo.cellForRow(at: IndexPath(row: 3, section: 0)) as? EditableTableViewCell, let ph = cell.infoValue?.text {
            if !InputValidator.phone(ph) {
                self.inputError = InputError(message: "Phone is incorrect!", row: 3)
            } else {
                newPhone = ph
            }
        }
        
        if let error = self.inputError {
            let alert = UIAlertController(title: "Input error", message: error.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        updateUserContact(newFirstName, newLastName, newPhone, newEmail)
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
    
    func updateUserContact(_ newFirstName: String, _ newLastName: String, _ newPhone: String, _ newEmail: String) {
        if let item = userContactList.filter("userId = %@", selectedContact.userId).first {
            try! self.realm.write({
                if !newFirstName.isEmpty { item.firstName = newFirstName }
                if !newLastName.isEmpty { item.lastName = newLastName }
                if !newEmail.isEmpty { item.email = newEmail }
                if !newPhone.isEmpty { item.phone = newPhone }
            })
        } else {
            try! self.realm.write({
                self.realm.add(selectedContact)
            })
        }
    }
}

fileprivate class InputValidator {
        // Name length from 1 to 30 inclusive
    static func name(_ name: String) -> Bool {
        return name.count > 0 && name.count < 31 && !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    static func email(_ email: String) -> Bool {
        return true
    }
    
    static func phone(_ phone: String) -> Bool {
        return true
    }
}


