//
//  FirebaseProvider.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/18.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation
import Firebase
import KeychainSwift

class FirebaseProvider {
    
    static let shared = FirebaseProvider()
    
    var userUid = KeychainSwift().get("uid")

    func parseSnapshot(snapshot: DataSnapshot, selected: Preference?) -> [Activity] {
        var results = [Activity]()
        if let objects = snapshot.value as? [String: AnyObject] {
            for (id, data) in objects {
                let id = id
                if
                    let type = data["type"] as? String,
                    let time = data["time"] as? String,
                    let placeName = data["place"] as? String,
                    let latitude = data["latitude"] as? String,
                    let longitude = data["longitude"] as? String,
                    let level = data["level"] as? String,
                    let address = data["address"] as? String,
                    let number = data["number"] as? Int,
                    let allNumber = data["allNumber"] as? Int,
                    let fee = data["fee"] as? Int,
                    let userUid = data["userUid"] as? String,
                    let author = data["author"] as? String
                {
                    let activity = Activity(id: id, level: Level(rawValue: level)!, place: Place(placeName: placeName, placeLatitude: latitude, placeLongitude: longitude), address: address, time: time, type: Sportstype(rawValue: type)!, number: number, allNumber: allNumber, fee: fee, author: author, authorUid: userUid)
                    if selected != nil {
                        if time == selected?.time && placeName == selected?.place && level == selected?.level.rawValue {
                            results.append(activity)
                        }
                    } else {
                        results.append(activity)
                    }
                }
            }
        }
        return results
    }
    
    func getData(selected: Preference?, completion: @escaping ([Activity]?, Error?) -> Void) {
        if selected != nil {
            Database.database().reference().child("activities").queryOrdered(byChild: "type").queryEqual(toValue: selected!.type.rawValue).observe(.value) { (snapshot: DataSnapshot) in
                let results = self.parseSnapshot(snapshot: snapshot, selected: selected)
                    completion(results, nil)
            }
        } else {
            Database.database().reference().child("activities").observe(.value) { (snapshot: DataSnapshot) in
                let results = self.parseSnapshot(snapshot: snapshot, selected: selected)
                completion(results, nil)
            }
        }
    }
    
    func getPosts(completion: @escaping ([Activity]?, Error?) -> Void) {
        
        var results = [String]()
        var posts = [Activity]()

        Database.database().reference().child("user_postId").queryOrdered(byChild: "user").queryEqual(toValue: userUid).observe(.value) { (snapshot: DataSnapshot) in
            if let objects = snapshot.value as? [String: AnyObject] {
                for (key, data) in objects {
                    if let postId = data["postId"] as? String {
                        results.append(postId)
                    }
                }
                for result in results {
                    Database.database().reference().child("activities").child(result).observe(.value, with: {
                        (snapshot) in
                        if let data = snapshot.value as? [String: AnyObject] {
                            if
                                let name = data["name"] as? String,
                                let type = data["type"] as? String,
                                let time = data["time"] as? String,
                                let placeName = data["place"] as? String,
                                let latitude = data["latitude"] as? String,
                                let longitude = data["longitude"] as? String,
                                let level = data["level"] as? String,
                                let address = data["address"] as? String,
                                let number = data["number"] as? Int,
                                let allNumber = data["allNumber"] as? Int,
                                let fee = data["fee"] as? Int,
                                let userUid = data["userUid"] as? String,
                                let author = data["author"] as? String

                            {
                                let activity = Activity(id: name, level: Level(rawValue: level)!, place: Place(placeName: placeName, placeLatitude: latitude, placeLongitude: longitude), address: address, time: time, type: Sportstype(rawValue: type)!, number: number, allNumber: allNumber, fee: fee, author: author, authorUid: userUid)
                                posts.append(activity)
                            }
                        }
                        completion(posts, nil)
                    })
                }
             }
        }
    }
    
    func getUser(completion: @escaping (UserSetting?, Error?) -> Void) {
        
        var user: UserSetting?
        
        if let uid = Auth.auth().currentUser?.uid {
            
            Database.database().reference().child(uid).observe(.value) { (snapshot) in
                
                if let userInfo = snapshot.value as? [String: Any],
                    let name = userInfo["name"] as? String,
                    let preference = userInfo["preference"] as? [String: String],
                    let city = preference["city"],
                    let level = preference["level"],
                    let type = preference["type"],
                    let time = preference["time"]
                {
                    user = UserSetting(name: name, preference: Preference(id: uid, type: Sportstype(rawValue: type)!, level: Level(rawValue: level)!, place: city, time: time))
                }
                completion(user, nil)
            }
            
        }
        
    }
}

