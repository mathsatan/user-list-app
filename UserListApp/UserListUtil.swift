//
//  UserListUtil.swift
//  UserListApp
//
//  Created by max kruchkov on 8/28/18.
//  Copyright © 2018 max kruchkov. All rights reserved.
//

import Foundation

class UserListUtil {
    static func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}

// For comfortable capitalize for contacts
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
