//
//  EditProfileViewController.swift
//  UserListApp
//
//  Created by max kruchkov on 8/28/18.
//  Copyright © 2018 max kruchkov. All rights reserved.
//

import UIKit


class EditableTableViewCell: UITableViewCell {
    @IBOutlet weak var infoName: UILabel!
    @IBOutlet weak var infoValue: UITextField!
}

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let infoCount = 4
    let userInfoLabels = ["First name", "Last name", "Email", "Phone"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "info_cell", for: indexPath) as! EditableTableViewCell
        infoCell.infoName?.text = userInfoLabels[indexPath.row]
        infoCell.infoValue?.text = "stub"
        return infoCell
    }
    

    @IBOutlet weak var profilePic: UIImageView!
    var selectedContact = UserContact()
    var tabIndex = 0
    
    @IBAction func backToMain(_ sender: UIBarButtonItem) {
        self.tabIndex = 0
        self.performSegue(withIdentifier: "from_edit_to_main", sender: self)
    }
    
    @IBAction func backToSaved(_ sender: UIBarButtonItem) {
        self.tabIndex = 1
        self.performSegue(withIdentifier: "from_edit_to_main", sender: self)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
