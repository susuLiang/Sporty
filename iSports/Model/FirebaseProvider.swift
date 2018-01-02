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
    
    var keyChain = KeychainSwift()
    
    func getData(completion: @escaping ([Activity]?, Error?) -> Void) {
        Database.database().reference().child("activities").observe(.value) { (snapshot: DataSnapshot) in
            var results = [Activity]()
            if let objects = snapshot.value as? [String: AnyObject] {
                for (id, data) in objects {
                    do {
                        let activity = try Activity(data, id: id)
                        results.append(activity)
                    }
                    catch {
                        print("Can not get data.")
                    }
                    completion(results, nil)
                }
            }
        }
    }
    
    func getTypeData(selected: Preference?, completion: @escaping ([Activity]?, Error?) -> Void) {
        Database.database().reference().child("activities").queryOrdered(byChild: "type").queryEqual(toValue: selected!.type).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            var results = [Activity]()
            if let objects = snapshot.value as? [String: AnyObject] {
                for (id, data) in objects {
                    if let time = data["time"] as? String,
                        let level = data["level"] as? String,
                        let place = data["place"] as? String {
                        
                        if (time == selected?.time || (selected?.time == "")) &&
                            (level == selected?.level?.rawValue || (selected?.level == nil)) &&
                            (place == selected?.place || (selected?.place == "")) {
                            do {
                                let activity = try Activity(data, id: id)
                                results.append(activity)
                            }
                            catch {
                                print("Can not query data.")
                            }
                        }
                    }
                }
            }
            completion(results, nil)
        }
    }

    func getPlaceAllActivities(place: Place?, completion: @escaping ([Activity]?, Error?) -> Void) {
        Database.database().reference().child("activities").queryOrdered(byChild: "place").queryEqual(toValue: place?.placeName).observe(.value) { (snapshot: DataSnapshot) in
            var results = [Activity]()
            if let objects = snapshot.value as? [String: AnyObject] {
                for (id, data) in objects {
                    do {
                        let activity = try Activity(data, id: id)
                        results.append(activity)
                    }
                    catch {
                        print("Can not get place data.")
                    }
                }
                completion(results, nil)
            }
        }
    }
    
    
    func getPosts(childKind: String, completion: @escaping ([Activity]?, [String]?, Error?) -> Void) {
        
        var keyUid = [String]()
        var results = [String]()
        var posts = [Activity]()
        
        let userCurrentUid = keyChain.get("uid")
        
        Database.database().reference().child("user_\(childKind)").queryOrdered(byChild: "user").queryEqual(toValue: userCurrentUid).observe(.value) { (snapshot: DataSnapshot) in
            if let objects = snapshot.value as? [String: AnyObject] {
                results = [String]()
                keyUid = [String]()
                for (key, data) in objects {
                    keyUid.append(key)
                    if let postId = data[childKind] as? String {
                        results.append(postId)
                    }
                }
                posts = [Activity]()
                for result in results {
                    Database.database().reference().child("activities").child(result).observeSingleEvent(of: .value, with: {
                        (snapshot) in
                        if let data = snapshot.value as? [String: AnyObject] {
                            let id = snapshot.key
                            do {
                                let activity = try Activity(data, id: id)
                                posts.append(activity)
                            }
                            catch {
                                print("Can not get users activities data.")
                            }
                        }
                        completion(posts, keyUid, nil)
                    })
                }
            } else {
                posts = [Activity]()
                keyUid = [String]()
                completion(posts, keyUid, nil)
            }
        }
    }
    
    func getUserProfile(completion: @escaping (UserSetting?, Error?) -> Void) {
        var userSetting: UserSetting? = nil
        if let userUid = keyChain.get("uid") {
            Database.database().reference().child("users").child(userUid).observe(.value) { (snapshot: DataSnapshot) in
                if let object = snapshot.value as? [String: AnyObject] {
                        do {
                            userSetting = try UserSetting(object)
                        }
                        catch {
                            print("Can not get users profile.")
                        }
                    }
                completion(userSetting, nil)
            }
        }
    }
    
    func getWhoJoin(activityId: String, completion: @escaping ([UserSetting]?, Error?) -> Void) {
        var usersId = [String]()
        var usersInfo = [UserSetting]()
        
        Database.database().reference().child("user_joinId").queryOrdered(byChild: "joinId").queryEqual(toValue: activityId).observe(.value) { (snapshot: DataSnapshot) in
            if let objects = snapshot.value as? [String: AnyObject] {
                usersId = [String]()
                for (key, data) in objects {
                    if let user = data["user"] as? String {
                        usersId.append(user)
                    }
                }
                usersInfo = [UserSetting]()
                for user in usersId {
                    Database.database().reference().child("users").child(user).observe(.value, with: {
                        (snapshot) in
                        if let data = snapshot.value as? [String: AnyObject] {
                            do {
                                let userInfo = try UserSetting(data)
                                usersInfo.append(userInfo)
                            }
                            catch {
                                print("Can not get users activities data.")
                            }
                        }
                        completion(usersInfo, nil)
                    })
                }
            }
        }
    }
}


