//
//  FirstViewController.swift
//  UserListApp
//
//  Created by max kruchkov on 8/27/18.
//  Copyright © 2018 max kruchkov. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

class HeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellUserName: UILabel!
    @IBOutlet weak var cellUserPhone: UILabel!
    @IBOutlet weak var cellUserPic: UIImageView!
}

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var usersTable: UITableView!
    
    var realm : Realm!
    var users: [UserContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        obtainUsers()
    }
    
    func obtainUsers() {
        Alamofire.request("https://randomuser.me/api/?results=3", method: .get).responseJSON { response in
            guard response.result.isSuccess else {
                print("Error has occured while fetching users data \(String(describing: response.result.error))")
                return
            }
            
            if let val = response.result.value, let userData = JSON(rawValue: val) {
                for (_, user) in userData["results"] {
                    let currentUser = UserContact()
                    currentUser.email = user["email"].stringValue
                    currentUser.phone = user["phone"].stringValue
                    currentUser.picUrl = user["picture"]["thumbnail"].stringValue
                    currentUser.firstName = user["name"]["first"].stringValue
                    currentUser.lastName = user["name"]["last"].stringValue
                    self.users.append(currentUser)
                }
                self.usersTable.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let headlineCell = tableView.dequeueReusableCell(withIdentifier: "user_cell", for: indexPath) as? HeadlineTableViewCell {
            headlineCell.cellUserName?.text = users[indexPath.row].firstName + " " + users[indexPath.row].lastName
            headlineCell.cellUserPhone?.text = users[indexPath.row].phone
            
            if let picUrl = URL(string: users[indexPath.row].picUrl) {
                self.getDataFromUrl(url: picUrl) { data, response, error in
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
    
    fileprivate func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}