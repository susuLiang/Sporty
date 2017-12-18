//
//  FirebaseProvider.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/18.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation
import Firebase

class FirebaseProvider {
    
    static let shared = FirebaseProvider()

    func getAllData(completion: @escaping ([Activity]?, Error?) -> Void) {
        Database.database().reference().child("activities").observe(.value) { (snapshot: DataSnapshot) in
            var results = [Activity]()
            if let objects = snapshot.value as? [String: AnyObject] {
                for (id, data) in objects {
                    let id = id
                    if
                        let type = data["type"] as? String,
                        let time = data["time"] as? String,
                        let place = data["place"] as? String,
                        let level = data["level"] as? String,
                        let address = data["address"] as? String,
                        let number = data["number"] as? Int,
                        let allNumber = data["allNumber"] as? Int,
                        let fee = data["fee"] as? Int,
                        let author = data["author"] as? String
                    {
                        results.append(Activity(id: id, level: Level(rawValue: level)!, place: place, address: address, time: time, type: Sportstype(rawValue: type)!, number: number, allNumber: allNumber, fee: fee, author: author))
                    }
                }
                completion(results, nil)
            }
        }
    }
}
