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
import KeychainSwift
import LGButton

class ShowDetailController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var courtLabel: UILabel!
    @IBOutlet weak var unJoinButton: LGButton!
    @IBOutlet weak var mapPlacedView: UIImageView!
    @IBOutlet weak var joinButton: LGButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    let keyChain = KeychainSwift()

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!

    var selectedActivity: Activity = Activity() {
        didSet {
            navigationItem.title = selectedActivity.name
            addressLabel.text = selectedActivity.address
            courtLabel.text = selectedActivity.place.placeName
            if let place = selectedActivity.place {
                mapPlacedView.addSubview(setMap(latitude: Double(place.placeLatitude) ?? 0.0,
                                                longitude: Double(place.placeLongitude) ?? 0.0))
            }
            setJoinButton()
        }
    }

    var myMatches: [Activity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        unJoinButton.isHidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ShowDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        collectionViewFlowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width / 3 - 20), height: 105)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setJoinButton() {
        var isMyMatch = false
        let uid = keyChain.get("uid")
        if selectedActivity.authorUid != uid {
            for myMatch in myMatches where myMatch.id == selectedActivity.id {
                isMyMatch = true
            }
            if selectedActivity.number < selectedActivity.allNumber && !isMyMatch {
                joinButton.titleString = "參加"
                joinButton.addTarget(self, action: #selector(self.join), for: .touchUpInside)
            } else if isMyMatch {
                joinButton.isHidden = true
                unJoinButton.isHidden = false
                unJoinButton.titleString = "已參加"
            } else if selectedActivity.number == selectedActivity.allNumber {
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

    @objc func join(_ sender: LGButton) {
        joinButton.isHidden = true
        unJoinButton.isHidden = false
        unJoinButton.titleString = "已參加"
        let uid = keyChain.get("uid")
        let ref = Database.database().reference()
        let joinId = selectedActivity.id
        let newVaule = selectedActivity.number + 1

        ref.child("user_joinId").childByAutoId().setValue(["user": uid, "joinId": joinId])
        ref.child("activities").child(joinId).child("number").setValue(newVaule)
        
    }
}

extension ShowDetailController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ActivityTitle.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ShowDetailCollectionViewCell.self, for: indexPath)
        let cellType = ActivityTitle(rawValue: indexPath.row) ?? ActivityTitle.type

        switch cellType {
        case .type:
            cell.setCell(title: cellType.title, detail: selectedActivity.type)
            
        case .level:
            cell.setCell(title: cellType.title, detail: selectedActivity.level)
            
        case .fee:
            cell.setCell(title: cellType.title, detail: selectedActivity.fee)
            
        case .time:
            let start = selectedActivity.time.index(selectedActivity.time.startIndex, offsetBy: 3)
            let end = selectedActivity.time.index(selectedActivity.time.startIndex, offsetBy: 4)
            let thisTime = selectedActivity.time.replacingCharacters(in: start..<end, with: "\n")
            cell.descriptionLabel.font = UIFont(name: "Arial", size: 16)
            cell.setCell(title: cellType.title, detail: thisTime)
            
        case .num:
            cell.setCell(title: cellType.title, detail: selectedActivity.number)
            
        case .allNum:
            cell.setCell(title: cellType.title, detail: selectedActivity.allNumber)
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

enum ActivityTitle: Int {
    
    case type
    case level
    case fee
    case time
    case num
    case allNum
    
    static let count = 6
    
    var title: String {
        switch self {
        case .type:
            return "類型"
        case .level:
            return "程度"
        case .fee:
            return "費用"
        case .time:
            return "時間"
        case .num:
            return "目前人數"
        case .allNum:
            return "總人數"
        }
    }
}
