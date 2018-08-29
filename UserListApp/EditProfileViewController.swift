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
            if row == 2 {
                if let newText = self.infoValue?.text {
                    if !InputValidator.email(newText) {
                        sender.layer.borderColor = UIColor.red.cgColor
                        sender.layer.borderWidth = 1
                        ownVC?.inputError = EditProfileViewController.InputError(message: "Email is incorrect", row: row)
                    }
                }
            }
            if row == 3 {
                if let newText = self.infoValue?.text {
                    if !InputValidator.phone(newText) {
                        sender.layer.borderColor = UIColor.red.cgColor
                        sender.layer.borderWidth = 1
                        ownVC?.inputError = EditProfileViewController.InputError(message: "Phone is incorrect", row: row)
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

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    struct InputError {
        let message: String
        let row: Int
    }
    
    var inputError: InputError?
    private var oldCustomPic = ""
    private var realm: Realm!
    private var userContactList: Results<UserContact> {
        get {
            return realm.objects(UserContact.self)
        }
    }
    
    @IBAction func changePhotoFromLibrary(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true) {
            }
        }
    }
    
    @IBAction func changePhotoFromCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    @objc internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            let imageData = UIImageJPEGRepresentation(image, 0.6)
            if let imgData = imageData {
                let compressedJPGImage = UIImage(data: imgData)
                self.profilePic.image = compressedJPGImage
                try! self.realm.write({
                    if self.oldCustomPic.isEmpty { self.oldCustomPic = self.selectedContact.customPic }
                    self.selectedContact.customPic = UUID().uuidString + ".png"
                })
            }
        } else {
            self.errorAlert(msg: "Image load error")
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func errorAlert(msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
            self.errorAlert(msg: error.message)
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
        
        if !selectedContact.customPic.isEmpty {
            if let customImage = UserListUtil.getSavedImage(named: selectedContact.customPic) {
                self.profilePic.image = customImage
            }
        } else {
            if let picUrl = URL(string: selectedContact.picUrl) {
                UserListUtil.getDataFromUrl(url: picUrl) { data, response, error in
                    guard let data = data, error == nil else { print("Error has occured: " + error.debugDescription); return }
                    DispatchQueue.main.async() {
                        self.profilePic.image = UIImage(data: data)
                    }
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
                if !newFirstName.isEmpty { selectedContact.firstName = newFirstName }
                if !newLastName.isEmpty { selectedContact.lastName = newLastName }
                if !newEmail.isEmpty { selectedContact.email = newEmail }
                if !newPhone.isEmpty { selectedContact.phone = newPhone }
                self.realm.add(selectedContact)
            })
        }
        
        if !self.selectedContact.customPic.isEmpty {
            if let imageForSave = self.profilePic.image {
                let isSaveSuccess = UserListUtil.saveImage(image: imageForSave, fileName: self.selectedContact.customPic)
                if isSaveSuccess && !self.oldCustomPic.isEmpty {
                    UserListUtil.deleteImage(fileName: self.oldCustomPic)
                }
            }
        }
    }
}

fileprivate class InputValidator {
        // Name length from 1 to 30 inclusive
    static func name(_ name: String) -> Bool {
        return name.count > 0 && name.count < 31 && !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    static func email(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
        "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func phone(_ phone: String) -> Bool {
        let PHONE_REGEX = "((?:\\+|00)[17](?: |\\-)?|(?:\\+|00)[1-9]\\d{0,2}(?: |\\-)?|(?:\\+|00)1\\-\\d{3}(?: |\\-)?)?(0\\d|\\([0-9]{3}\\)|[1-9]{0,3})(?:((?: |\\-)[0-9]{2}){4}|((?:[0-9]{2}){4})|((?: |\\-)[0-9]{3}(?: |\\-)[0-9]{4})|([0-9]{7}))"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: phone)
        return result
    }
}


