//
//  UserTabBarController.swift
//  UserListApp
//
//  Created by max kruchkov on 8/28/18.
//  Copyright © 2018 max kruchkov. All rights reserved.
//

import UIKit

class UserTabBarController: UITabBarController {

    var tabIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = tabIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
