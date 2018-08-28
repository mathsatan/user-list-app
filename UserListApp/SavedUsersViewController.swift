//
//  SavedUsersViewController.swift
//  UserListApp
//
//  Created by max kruchkov on 8/27/18.
//  Copyright © 2018 max kruchkov. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var cellUserPic: UIImageView!
    @IBOutlet weak var cellUserName: UILabel!
    @IBOutlet weak var cellUserPhone: UILabel!
}

class SavedUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var savedUsersTable: UITableView!
    
    var savedUsers: [UserContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user1 = UserContact()
        user1.email = "asd@asd.com"
        user1.phone = "0664787366"
        user1.picUrl = "https://www.shareicon.net/data/48x48/2015/09/18/103160_man_512x512.png"
        user1.firstName = "Max"
        user1.lastName = "Kruchkov"
        
        let user2 = UserContact()
        user2.email = "asd2@asd.com"
        user2.phone = "0671094822"
        user2.picUrl = "https://www.shareicon.net/data/48x48/2015/09/18/103160_man_512x512.png"
        user2.firstName = "Miha"
        user2.lastName = "Nazarenko"
        savedUsers.append(user1)
        savedUsers.append(user2)
        // Do any additional setup after loading the view, typically from a nib.
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
            
            if let picUrl = URL(string: savedUsers[indexPath.row].picUrl) {
                UserListUtil.getDataFromUrl(url: picUrl) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async() {
                        headlineCell.cellUserPic?.image = UIImage(data: data)
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
            self.savedUsers.remove(at: indexPath.row)
            self.savedUsersTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditProfileViewController {
            vc.selectedContact = selectedUser
        }
    }
    
    private var selectedUser = UserContact()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = savedUsers[indexPath.row]
        self.performSegue(withIdentifier: "edit_saved_contact", sender: selectedUser)
    }
}
