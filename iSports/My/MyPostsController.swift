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

class MyPostsController: UITableViewController, IndicatorInfoProvider {
    
    var user: UserSetting?
    
    let userUid = KeychainSwift().get("uid")
    
    var itemInfo = IndicatorInfo(title: "MyPosts")
    
    var myPosts = [Activity]()
    
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

        cell.placeLabel.text = myPosts[indexPath.row].id
        
        cell.joinButton.backgroundColor = UIColor.clear
        
        cell.joinButton.tintColor = UIColor.clear

        return cell
    }
    
    func getPosts() {
        
        FirebaseProvider.shared.getPosts(childKind: "postId", completion: { (posts, error) in
            self.myPosts = posts!
            self.tableView.reloadData()
        })
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
   
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
