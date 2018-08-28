//
//  EditProfileViewController.swift
//  UserListApp
//
//  Created by max kruchkov on 8/28/18.
//  Copyright © 2018 max kruchkov. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePic.layer.cornerRadius = profilePic.frame.size.width / 2.0
        self.profilePic.clipsToBounds = true
        print("EditProfileViewController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
