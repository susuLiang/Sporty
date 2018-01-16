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
                    } catch {
                        print("Can not get data.")
                    }
                }
                results.sort(by: { $0.postedTime > $1.postedTime })
                completion(results, nil)
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
                            (level == selected?.level || (selected?.level == "")) &&
                            (place == selected?.place || (selected?.place == "")) {
                            do {
                                let activity = try Activity(data, id: id)
                                results.append(activity)
                            } catch {
                                print("Can not query data.")
                            }
                        }
                    }
                }
            }
            results.sort(by: { $0.postedTime > $1.postedTime })
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
                    } catch {
                        print("Can not get place data.")
                    }
                }
                results.sort(by: { $0.postedTime > $1.postedTime })
                completion(results, nil)
            }
        }
    }

    func getPosts(childKind: String, completion: @escaping ([String: Activity]?, Error?) -> Void) {

        var results = [String: String]()
        var posts = [String: Activity]()

        let userCurrentUid = keyChain.get("uid")

        Database.database().reference().child("user_\(childKind)").queryOrdered(byChild: "user").queryEqual(toValue: userCurrentUid).observe(.value) { (snapshot: DataSnapshot) in
            if let objects = snapshot.value as? [String: AnyObject] {
                results = [String: String]()
                for (key, data) in objects {
                    if let postId = data[childKind] as? String {
                        results.updateValue(postId, forKey: key)
                    }
                }
                posts = [String: Activity]()
                for (key, result) in results {
                    Database.database().reference().child("activities").child(result).observeSingleEvent(of: .value, with: {
                        (snapshot) in
                        if let data = snapshot.value as? [String: AnyObject] {
                            let id = snapshot.key
                            do {
                                let activity = try Activity(data, id: id)
                                posts.updateValue(activity, forKey: key)
                            } catch {
                                print("Can not get users activities data.")
                            }
                        }
                        completion(posts, nil)
                    })
                }
            } else {
                posts = [String: Activity]()
                completion(posts, nil)
            }
        }
    }

    func getUserProfile(userUid: String, completion: @escaping (UserSetting?, Error?) -> Void) {
        var userSetting: UserSetting? = nil
            Database.database().reference().child("users").child(userUid).observe(.value) { (snapshot: DataSnapshot) in
                if let object = snapshot.value as? [String: AnyObject] {
                    do {
                        userSetting = try UserSetting(object)
                    } catch {
                        print("Can not get users profile.")
                    }
                }
            completion(userSetting, nil)
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
                            } catch {
                                print("Can not get users activities data.")
                            }
                        }
                        completion(usersInfo, nil)
                    })
                }
            } else {
                usersInfo = [UserSetting]()
                completion(usersInfo, nil)
            }
        }
    }

    func getMessage(postUid: String, completion: @escaping ([Message]?, Error?) -> Void ) {
        var messages = [Message]()
//        var userUids = [String]()

        Database.database().reference().child("messages").queryOrdered(byChild: "postUid").queryEqual(toValue: postUid).observe(.value) { (snapshot: DataSnapshot) in
            if let objects = snapshot.value as? [String: AnyObject] {
                messages = [Message]()
                for (key, object) in objects {
                    if let message = object["message"] as? String,
                        let userUid = object["userUid"] as? String,
                        let date = object["date"] as? String {
                        messages.append(Message(message: message, date: date, userUid: userUid))
//                        userUids.append(userUid)
                    }
                }
            }
           completion(messages, nil)
        }
    }
}
