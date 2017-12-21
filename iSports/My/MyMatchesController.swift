//
//  MyMatchController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/20.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase
import KeychainSwift

class MyMatchesController: UITableViewController, IndicatorInfoProvider {
    
    var itemInfo = IndicatorInfo(title: "MyMatches")
    
    let userUid = KeychainSwift().get("uid")
    
    var myMatches = [Activity]()
    
    var keyUid = [String]()

    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        
        self.itemInfo = itemInfo
        
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableCell()
        
        FirebaseProvider.shared.getPosts(childKind: "joinId", completion: { (posts, keyUid, error) in
            self.myMatches = posts!
            self.keyUid = keyUid!
            self.tableView.reloadData()
        })

    }
    
    func setupTableCell() {
        
        let nib = UINib(nibName: "ListsCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myMatches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ListsCell else { fatalError() }
        let result = myMatches[indexPath.row]
        
        cell.titleLabel.text = result.id
        cell.timeLabel.text = result.time
        cell.levelLabel.text = result.level.rawValue
        cell.typeLabel.text = result.type.rawValue
        cell.placeLabel.text = result.place.placeName
        cell.numLabel.text = "\(result.number) / \(result.allNumber)"
        
        cell.joinButton.tintColor = UIColor.gray
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activityView = UINib.load(nibName: "ActivityView") as! ActivityController
        activityView.selectedActivity = myMatches[indexPath.row]
        navigationController?.pushViewController(activityView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let uid = keyUid[indexPath.row]
        
        if editingStyle == .delete {
            
            let ref = Database.database().reference()
            ref.child("user_joinId").child(uid).removeValue()
            
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    
}
