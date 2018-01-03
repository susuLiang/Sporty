//
//  User.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/20.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation

struct UserSetting {

    var name: String

    var email: String

    var urlString: String?

    var preference: Preference

    init(_ json: Any) throws {

        var preference: Preference? = nil

        guard let data = json as? [String: AnyObject] else { throw JSONError.userSettingJsonError}

        guard let name = data["name"] as? String,

            let email = data["email"] as? String,

            let prefer = data["preference"] as? [String: String]  else { throw JSONError.jsonError }

        self.name = name

        self.email = email

        if let imageURL = data["imageURL"] as? String {

            self.urlString = imageURL

        }

        guard let city = prefer["city"],

            let level = prefer["level"],

            let time = prefer["time"],

            let type = prefer["type"] else { throw JSONError.jsonError }

        self.preference = Preference(type: type, level: level, place: city, time: time)
    }

}
