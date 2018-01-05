//
//  ShowDetailController.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/5.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import NVActivityIndicatorView
import KeychainSwift
import LGButton
import SkyFloatingLabelTextField

class ShowDetailController: UIViewController {

    @IBOutlet weak var unJoinButton: LGButton!
    @IBOutlet weak var mapPlacedView: UIImageView!
    @IBOutlet weak var joinButton: LGButton!
    @IBOutlet weak var tableView: UITableView!
    
    let loadingIndicator = LoadingIndicator()
    let keyChain = KeychainSwift()
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?

    var activityTitleInCell: [ActivityTitle.RawValue] = [
        ActivityTitle.name.rawValue,
        ActivityTitle.type.rawValue,
        ActivityTitle.address.rawValue,
        ActivityTitle.level.rawValue,
        ActivityTitle.time.rawValue,
        ActivityTitle.court.rawValue,
        ActivityTitle.fee.rawValue,
        ActivityTitle.num.rawValue,
        ActivityTitle.allNum.rawValue
    ]

    var selectedActivity: Activity? {
        didSet {
            if let selectedActivity = selectedActivity {
                navigationItem.title = selectedActivity.name
                self.nowPlace = (selectedActivity.place.placeLatitude, selectedActivity.place.placeLongitude, selectedActivity.address)
                setJoinButton()
            }
        }
    }
    
    var myMatches = [Activity]()

    var nowPlace: (latitude: String, longitude: String, address: String)? {
        didSet {
            if let lat = nowPlace?.latitude, let lng = nowPlace?.longitude {
                mapPlacedView.addSubview(setMap(latitude: Double(lat)!, longitude: Double(lng)!))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        unJoinButton.isHidden = true
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        getPosts()

        setupTableCell()

        view.addSubview(tableView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getPosts() {
        FirebaseProvider.shared.getPosts(childKind: "joinId", completion: { (posts, keyUid, error) in
            if error == nil {
                self.myMatches = posts!
                self.setJoinButton()
            }
        })
    }

    func setJoinButton() {
        var isMyMatch = false
        let uid = keyChain.get("uid")

        if let selected = selectedActivity {

            if selected.authorUid != uid {
                for myMatch in myMatches where myMatch.id == selected.id {
                    isMyMatch = true
                }
                if selected.number < selected.allNumber && !isMyMatch {
                    joinButton.titleString = "參加"
                    joinButton.addTarget(self, action: #selector(self.join), for: .touchUpInside)
                } else if isMyMatch {
                    joinButton.isHidden = true
                    unJoinButton.isHidden = false
                    unJoinButton.titleString = "已參加"
                } else if selected.number == selected.allNumber {
                    joinButton.isHidden = true
                    unJoinButton.isHidden = false
                    unJoinButton.titleString = "人數已滿"
                }

            } else {
                joinButton.backgroundColor = .clear
                joinButton.isHidden = true
                unJoinButton.isHidden = true
            }
        }
    }
    
    @objc func join(_ sender: LGButton) {
        joinButton.isHidden = true
        unJoinButton.isHidden = false
        unJoinButton.titleString = "已參加"
        let uid = keyChain.get("uid")
        let ref = Database.database().reference()
        if let selected = selectedActivity {
            let joinId = selected.id
            let newVaule = selected.number + 1
            
            ref.child("user_joinId").childByAutoId().setValue(["user": uid, "joinId": joinId])
            ref.child("activities").child(joinId).child("number").setValue(newVaule)
        }
    }
}

extension ShowDetailController: UITableViewDelegate, UITableViewDataSource {

    func setupTableCell() {
        let nib = UINib(nibName: "ShowDetailCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityTitleInCell.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ShowDetailCell else {
            fatalError("Invalid ShowDetailCell")
        }

        guard let result = selectedActivity else {
            print("selected nil")
            return cell
        }

        let thisActivityTitle = activityTitleInCell[indexPath.row]

        switch thisActivityTitle {
        case "名稱":
            cell.setCell(title: "名稱", detail: result.name)
        case "類型":
            cell.setCell(title: "類型", detail: result.type)
        case "地址":
            cell.setCell(title: "地址", detail: result.address)
        case "程度":
            cell.setCell(title: "程度", detail: result.level)
        case "場地":
            cell.setCell(title: "場地", detail: result.place.placeName)
        case "費用":
            cell.setCell(title: "費用", detail: result.fee)
        case "時間":
            cell.setCell(title: "時間", detail: result.time)
        case "目前人數":
            cell.setCell(title: "目前人數", detail: result.number)
        case "總需求人數":
            cell.setCell(title: "總需求人數", detail: result.allNumber)
        default: break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension ShowDetailController: CLLocationManagerDelegate {

    func setMap(latitude: Double, longitude: Double) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: mapPlacedView.frame.height), camera: camera)
        mapView.isMyLocationEnabled = false
        mapView.settings.myLocationButton = false

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView
        return mapView
    }

}

enum ActivityTitle: String {
    case name = "名稱"
    case type =  "類型"
    case address = "地址"
    case level = "程度"
    case court = "場地"
    case fee = "費用"
    case time = "時間"
    case num = "目前人數"
    case allNum = "總需求人數"
}
