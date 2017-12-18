//
//  CourtsProvider.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/18.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation
import Alamofire

enum GetCourtError: Error {
    
    case responseError
    case invalidResponseData
}

class CourtsProvider {
    
    static let shared = CourtsProvider()
    
    func getApiData(city: String, gymType: String, completion: @escaping ([Court]?, Error?) -> Void ) {
        let urlString = "https://iplay.sa.gov.tw/odata/GymSearch?$format=application/json;odata.metadata=none&City=\(city)&GymType=\(gymType)"
        var courts = [Court]()
        Alamofire.request(urlString).responseJSON { response in
            if let resultsValue = response.result.value as? [String: AnyObject] {
                        if let results = resultsValue["value"] as? [[String: AnyObject]] {
                    for result in results {
                        guard
                            let gymID = result["GymID"] as? Int,
                            let name = result["Name"] as? String,
                            let operationTel = result["OperationTel"] as? String,
                            let address = result["Address"] as? String,
                            let rate = result["Rate"] as? Int,
                            let rateCount = result["RateCount"] as? Int,
                            let gymFuncList = result["GymFuncList"] as? String,
                            let latLng = result["LatLng"] as? String
                            else { return }
                        
                        var latitudeAndLongitude = latLng.components(separatedBy: ",")
                        var latitude = ""
                        var longitude = ""
                        
                        // MARK: Get latitude and longitude
                        if latitudeAndLongitude.count == 2 {
                            latitude = latitudeAndLongitude[0]
                            longitude = latitudeAndLongitude[1]
                        } else {
                            print("=== The Latitude and Longitude are wrong -> Court: \(name)")
                        }
                        
                        let court = Court(courtID: gymID, name: name, tel: operationTel, address: address, rate: rate, rateCount: rateCount, gymFuncList: gymFuncList, latitude: latitude, longitude: longitude)
                        
                        courts.append(court)
                    }
                    // todo: 過濾球場
                    completion(courts, nil)
                } else { completion(nil, GetCourtError.invalidResponseData) }
            }
        }
    }
  
}



