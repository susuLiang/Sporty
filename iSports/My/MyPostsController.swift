//
//  PendingController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/20.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import KeychainSwift
import Firebase

class MyPostsController: UITableViewController, IndicatorInfoProvider {
    
    var user: UserSetting?
    
    let userUid = Auth.auth().currentUser?.uid
    
    var itemInfo = IndicatorInfo(title: "MyPosts")
    
    var myPosts = [Activity]()
    
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
        
        getPosts()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        getPosts()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTableCell() {
        
        let nib = UINib(nibName: "ListsCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ListsCell else { fatalError() }
        
        let result = myPosts[indexPath.row]
        cell.titleLabel.text = result.name
        cell.timeLabel.text = result.time
        cell.levelLabel.text = result.level.rawValue
        cell.placeLabel.text = result.place.placeName
        cell.numLabel.text = "\(result.number) / \(result.allNumber)"
        
        cell.joinButton.backgroundColor = UIColor.clear
        
        cell.joinButton.tintColor = UIColor.clear

        return cell
    }
    
    func getPosts() {
        
        FirebaseProvider.shared.getPosts(childKind: "postId", completion: { (posts, keyUid, error) in
            self.myPosts = posts!
            self.keyUid = keyUid!
            self.tableView.reloadData()
        })
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let postId = myPosts[indexPath.row].id
        let uid = keyUid[indexPath.row]
        
        if editingStyle == .delete {
            
            let ref = Database.database().reference()
            ref.child("activities").child(postId).removeValue()
            ref.child("user_postId").child(uid).removeValue()

        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activityView = UINib.load(nibName: "ActivityView") as! ActivityController
        activityView.selectedActivity = myPosts[indexPath.row]
        self.navigationController?.pushViewController(activityView, animated: true)
    }
}
