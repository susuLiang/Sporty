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

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var courtLabel: UILabel!
    @IBOutlet weak var unJoinButton: LGButton!
    @IBOutlet weak var mapPlacedView: UIImageView!
    @IBOutlet weak var joinButton: LGButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    let loadingIndicator = LoadingIndicator()
    let keyChain = KeychainSwift()

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?

    var activityTitleInCell: [ActivityTitle.RawValue] = [
        ActivityTitle.type.rawValue,
        ActivityTitle.level.rawValue,
        ActivityTitle.time.rawValue,
        ActivityTitle.fee.rawValue,
        ActivityTitle.num.rawValue,
        ActivityTitle.allNum.rawValue
    ]

    var selectedActivity: Activity? {
        didSet {
            if let selectedActivity = selectedActivity {
                navigationItem.title = selectedActivity.name
                addressLabel.text = selectedActivity.address
                courtLabel.text = selectedActivity.place.placeName
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
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ShowDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        collectionViewFlowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width / 3 - 20), height: 105)
        getPosts()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getPosts() {
        FirebaseProvider.shared.getPosts(childKind: "joinId", completion: { (posts, error) in
            if error == nil, let posts = posts {
                self.myMatches = Array(posts.values)
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

extension ShowDetailController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activityTitleInCell.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ShowDetailCollectionViewCell else {
            fatalError("Invalid ShowDetailCell")
        }
        guard let result = selectedActivity else {
            print("selected nil")
            return cell
        }

        let thisActivityTitle = activityTitleInCell[indexPath.row]

        switch thisActivityTitle {

        case "類型":
            cell.setCell(title: "類型", detail: result.type)
        case "程度":
            cell.setCell(title: "程度", detail: result.level)
        case "費用":
            cell.setCell(title: "費用", detail: result.fee)
        case "時間":
            let start = result.time.index(result.time.startIndex, offsetBy: 3)
            let end = result.time.index(result.time.startIndex, offsetBy: 4)
            let thisTime = result.time.replacingCharacters(in: start..<end, with: "\n")
            cell.descriptionLabel.font = UIFont(name: "Arial", size: 16)
            cell.setCell(title: "時間", detail: thisTime)
        case "目前人數":
            cell.setCell(title: "目前人數", detail: result.number)
        case "總人數":
            cell.setCell(title: "總人數", detail: result.allNumber)
        default: break
        }
        return cell

    }
}

extension ShowDetailController: CLLocationManagerDelegate {

    func setMap(latitude: Double, longitude: Double) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: mapPlacedView.frame.height), camera: camera)
        mapView.settings.scrollGestures = false
        mapView.settings.zoomGestures = false
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
    case type =  "類型"
    case level = "程度"
    case fee = "費用"
    case time = "時間"
    case num = "目前人數"
    case allNum = "總人數"
}
