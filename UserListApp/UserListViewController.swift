//
//  UserListViewController.swift
//  UserListApp
//
//  Created by max kruchkov on 8/27/18.
//  Copyright © 2018 max kruchkov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HeadlineTableViewCell: UITableViewCell {
    @IBOutlet weak var cellUserName: UILabel!
    @IBOutlet weak var cellUserPhone: UILabel!
    @IBOutlet weak var cellUserPic: UIImageView!
}

class UserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var usersTable: UITableView!
    
    var users: [UserContact] = []
    let fetchUserNumber = 10
    var pageNumber = 0
    let totalEntries = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        obtainUsers()
        self.usersTable.reloadData()
    }
    
    func obtainUsers() {
        Alamofire.request("https://randomuser.me/api/?page=\(pageNumber)&results=\(fetchUserNumber)", method: .get).responseJSON { response in
            guard response.result.isSuccess else {
                print("Error has occured while fetching users data \(String(describing: response.result.error))")
                return
            }
            
            if let val = response.result.value, let userData = JSON(rawValue: val) {
                for (_, user) in userData["results"] {
                    let currentUser = UserContact()
                    currentUser.userId = user["login"]["uuid"].stringValue
                    currentUser.email = user["email"].stringValue
                    currentUser.phone = user["phone"].stringValue
                    currentUser.picUrl = user["picture"]["large"].stringValue
                    currentUser.firstName = user["name"]["first"].stringValue.capitalizingFirstLetter()
                    currentUser.lastName = user["name"]["last"].stringValue.capitalizingFirstLetter()
                    self.users.append(currentUser)
                }
                self.perform(#selector(self.reloadUserList), with: nil, afterDelay: 1.0)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let headlineCell = tableView.dequeueReusableCell(withIdentifier: "user_cell", for: indexPath) as? HeadlineTableViewCell {
            headlineCell.cellUserName?.text = users[indexPath.row].firstName + " " + users[indexPath.row].lastName
            headlineCell.cellUserPhone?.text = users[indexPath.row].phone
            
            headlineCell.cellUserPic.layer.cornerRadius = headlineCell.cellUserPic.frame.size.width / 2.0
            headlineCell.cellUserPic.clipsToBounds = true
            
            if let picUrl = URL(string: users[indexPath.row].picUrl) {
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
        cell.textLabel?.text = users[indexPath.row].firstName + " " + users[indexPath.row].lastName
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditProfileViewController {
            vc.selectedContact = self.selectedUser
        }
    }
    
    private var selectedUser = UserContact()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUser = users[indexPath.row]
        self.performSegue(withIdentifier: "edit_user_segue", sender: selectedUser)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == users.count - 1 && users.count < totalEntries {
            pageNumber = pageNumber + 1
            obtainUsers()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    @objc func reloadUserList() {
        self.usersTable.reloadData()
    }
    
}
