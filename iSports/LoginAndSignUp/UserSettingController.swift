//
//  UserSettingController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase

enum PreferenceSetting: String {
    
    case type, level, city, time
   
}

class UserSettingController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedItems = [String]()
    var userUid: String = ""
    
    var city: [String] = ["臺北市", "新北市", "基隆市", "桃園市", "新竹市", "新竹縣", "苗栗縣", "臺中市", "彰化縣", "南投縣", "雲林縣", "嘉義市", "嘉義縣", "臺南市", "高雄市", "屏東縣", "宜蘭縣", "花蓮縣", "臺東縣", "澎湖縣", "金門縣" ]
    var type: [Sportstype.RawValue] = ["籃球", "排球", "棒球", "足球", "羽球", "網球"]
    var level: [Level] = [.A, .B, .C, .D]
    var time: [String] = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"]
    var preferenceSetting: [PreferenceSetting] = [.type, .city, .level, .time]

    @IBAction func saveButton(_ sender: Any) {
        
        let value = ["type": selectedItems[0], "city": selectedItems[1], "level": selectedItems[2], "time": selectedItems[3]]
        
        let ref = Database.database().reference().child("users").child(userUid)
        
        ref.child("preference").setValue(value)

        let tabBarController = TabBarController(itemTypes: [ .map, .home, .my])
        tabBarController.selectedIndex = 1
        self.present(tabBarController, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return preferenceSetting.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return type.count
        case 1:
            return city.count
        case 2:
            return level.count
        case 3:
            return time.count
        default:
            return 1
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? UserSettingCell else {fatalError("invalid")}
            switch indexPath.section {
                
            case 0:
                
                cell.nameLabel.text = type[indexPath.row]
                
            case 1:
                
                cell.nameLabel.text = city[indexPath.row]
                
            case 2:
                
                cell.nameLabel.text = level[indexPath.row].rawValue
                
            case 3:
                
                cell.nameLabel.text = time[indexPath.row]
                
            default:
                break
        }
        
        return cell

    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
           
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath) as! HeaderView
                headerView.headerLabel.text = preferenceSetting[indexPath.section].rawValue
                return headerView
 
        default:
            assert(false, "Unexpected element kind")
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            selectedItems.append(type[indexPath.row])
        case 1:
            selectedItems.append(city[indexPath.row])
        case 2:
            selectedItems.append(level[indexPath.row].rawValue)
        case 3:
            selectedItems.append(time[indexPath.row])
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
