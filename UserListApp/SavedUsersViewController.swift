//
//  SavedUsersViewController.swift
//  UserListApp
//
//  Created by max kruchkov on 8/27/18.
//  Copyright © 2018 max kruchkov. All rights reserved.
//

import UIKit
import RealmSwift

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var cellUserPic: UIImageView!
    @IBOutlet weak var cellUserName: UILabel!
    @IBOutlet weak var cellUserPhone: UILabel!
}

class SavedUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var savedUsersTable: UITableView!
    
    var realm: Realm!
    
    var savedUsers: Results<UserContact> {
        get {
            return realm.objects(UserContact.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let headlineCell = tableView.dequeueReusableCell(withIdentifier: "saved_cell", for: indexPath) as? UserTableViewCell {
            headlineCell.cellUserName?.text = savedUsers[indexPath.row].firstName + " " + savedUsers[indexPath.row].lastName
            headlineCell.cellUserPhone?.text = savedUsers[indexPath.row].phone
            
            headlineCell.cellUserPic.layer.cornerRadius = headlineCell.cellUserPic.frame.size.width / 2.0
            headlineCell.cellUserPic.clipsToBounds = true
            if !savedUsers[indexPath.row].customPic.isEmpty {
                if let customImage = UserListUtil.getSavedImage(named: savedUsers[indexPath.row].customPic) {
                    headlineCell.cellUserPic?.image = customImage
                }
            } else {
                if let picUrl = URL(string: savedUsers[indexPath.row].picUrl) {
                    UserListUtil.getDataFromUrl(url: picUrl) { data, response, error in
                        guard let data = data, error == nil else { return }
                        DispatchQueue.main.async() {
                            headlineCell.cellUserPic?.image = UIImage(data: data)
                        }
                    }
                }
            }
            
            headlineCell.accessoryType = .disclosureIndicator
            return headlineCell
        }
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "user_cell")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = savedUsers[indexPath.row].firstName + " " + savedUsers[indexPath.row].lastName
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = savedUsers[indexPath.row]
            try! self.realm.write({
                self.realm.delete(item)
            })
            
            self.savedUsersTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditProfileViewController {
            vc.selectedContact = selectedUser
        }
    }
    
    private var selectedUser = UserContact()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UserListUtil.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = savedUsers[indexPath.row]
        self.performSegue(withIdentifier: "edit_saved_contact", sender: selectedUser)
    }
}
