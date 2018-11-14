//
//  PendingController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/20.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase
import SCLAlertView
import Crashlytics

class MyPostsController: UIViewController, IndicatorInfoProvider {

    var user: UserSetting?
    var tableView = UITableView()
    var itemInfo = IndicatorInfo(title: "MyPosts")
    var myPosts: [Activity] = []
    var keyUid: [String] = []

    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        view.backgroundColor = .white
        getPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTableView() {
        tableView.frame = view.frame
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(nibWithCellClass: MyPostsCell.self)
    }

    func getPosts() {
        FirebaseProvider.shared.getPosts(childKind: "postId", completion: { (posts, error) in
            if error == nil, let posts = posts {
                self.myPosts = Array(posts.values)
                self.keyUid = Array(posts.keys)
                self.tableView.reloadData()
            }
        })
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}

extension MyPostsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: MyPostsCell.self, for: indexPath)
        let result = myPosts[indexPath.row]
        cell.configCell(post: result)
        cell.delegate = self
        return cell
    }
}

extension MyPostsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension MyPostsController: MyPostsCellButtonDelegate {
    
    func tapMessageButton(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("It's not the right cell.")
            return
        }
        
        let thisActivity = myPosts[indexPath.row]
        
        // swiftlint:disable force_cast
        let messagesView = UINib.load(nibName: "MessagesViewController") as! MessagesViewController
        // swiftlint:enable force_cast
        
        messagesView.thisActivityUid = thisActivity.id
        messagesView.view.frame = CGRect(x: 0,
                                         y: 0,
                                         width: UIScreen.main.bounds.width,
                                         height: UIScreen.main.bounds.height - (self.tabBarController?.tabBar.frame.height)! * 2 - (self.navigationController?.navigationBar.frame.height)!)
        
        self.addChild(messagesView)
        self.view.addSubview(messagesView.view)
        messagesView.didMove(toParent: self)
    }
    
    func tapEditButton(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("It's not the right cell.")
            return
        }
        
        let activityView = ActivityViewController.initVC(type: .edit)
        activityView.activityViewModel.thisPost = myPosts[indexPath.row]
        self.navigationController?.pushViewController(activityView, animated: true)
    }
    
    func tapSeeWhoButton(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("It's not the right cell.")
            return
        }
        
        let whoJoinView = WhoJoinController()
        whoJoinView.thisActivity = myPosts[indexPath.row]
        self.navigationController?.pushViewController(whoJoinView, animated: true)
    }
    
    func tapDeleteButton(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("It's not the right cell.")
            return
        }
        
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton(NSLocalizedString("SURE", comment: ""), action: {
            let uid = self.keyUid[indexPath.row]
            let postId = self.myPosts[indexPath.row].id
            let ref = Database.database().reference()
            self.keyUid.remove(at: indexPath.row)
            ref.child("activities").child(postId).removeValue()
            ref.child("user_postId").child(uid).removeValue()
        })
        
        alertView.addButton(NSLocalizedString("NO", comment: "")) { }
        alertView.showWarning(NSLocalizedString("Sure to delete it ?", comment: ""), subTitle: "")
    }
    
}
