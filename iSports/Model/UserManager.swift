//
//  UserManager.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/19.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation
import Firebase

class UserManager {
    
    static let shared = UserManager()
    
    func getUserInfo(currentUserId: String, completion: @escaping (User?, Error?) -> Void) {
        
        var user: User?

        let ref = Database.database().reference().child("users").child(currentUserId)
        ref.observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                guard let userData = snapshot.value as? [String: Any]
                    else { return }
                
                
                
                
                
            }

            
        })

    }
}
