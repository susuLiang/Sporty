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
import SCLAlertView

class MyPostsController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider {

    var user: UserSetting?
    
    var tableView = UITableView()

    let userUid = Auth.auth().currentUser?.uid

    var itemInfo = IndicatorInfo(title: "MyPosts")

    var myPosts = [Activity]()

    var keyUid = [String]()

    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.frame
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.backgroundColor = .white
        setupTableCell()
        getPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupTableCell() {
        let nib = UINib(nibName: "MyPostsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none

    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myPosts.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyPostsCell else { fatalError() }

        let result = myPosts[indexPath.row]
        cell.nameLabel.text = result.name
        cell.numLabel.text = "\(result.number) / \(result.allNumber)"

        switch result.type {
        case "羽球": cell.typeImage.image = UIImage(named: "badminton")!
        case "棒球": cell.typeImage.image = UIImage(named: "baseball")!
        case "籃球": cell.typeImage.image = UIImage(named: "basketball")!
        case "排球": cell.typeImage.image = UIImage(named: "volleyball")!
        case "網球": cell.typeImage.image = UIImage(named: "tennis")!
        case "足球": cell.typeImage.image = UIImage(named: "soccer")!
        default:
            return cell
        }

        cell.seeWhoButton.addTarget(self, action: #selector(seeWhoJoin), for: .touchUpInside)
        cell.editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)
        cell.deleteButton.addTarget(self, action: #selector(deleteIt), for: .touchUpInside)
        cell.messageButton.addTarget(self, action: #selector(message), for: .touchUpInside)
        return cell
    }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func getPosts() {
        FirebaseProvider.shared.getPosts(childKind: "postId", completion: { (posts, error) in
            if error == nil, let posts = posts {
                self.myPosts = Array(posts.values)
                self.tableView.reloadData()
            }
        })
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    @objc func message(_ sender: UIButton) {
         guard let cell = sender.superview?.superview?.superview?.superview as? MyPostsCell,
            let indexPath = tableView.indexPath(for: cell) else {
                print("It's not the right cell.")
                return
        }
        
        let thisActivity = myPosts[indexPath.row]
        
        // swiftlint:disable force_cast
        let messagesView = UINib.load(nibName: "MessagesViewController") as! MessagesViewController
        // swiftlint:enable force_cast
        
        messagesView.thisActivityUid = thisActivity.id
        messagesView.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (self.tabBarController?.tabBar.frame.height)! * 2 - (self.navigationController?.navigationBar.frame.height)!)
        
        self.addChildViewController(messagesView)
        self.view.addSubview(messagesView.view)
        messagesView.didMove(toParentViewController: self)
    }

    @objc func seeWhoJoin(_ sender: UIButton) {
        guard let cell = sender.superview?.superview?.superview?.superview as? MyPostsCell,
            let indexPath = tableView.indexPath(for: cell) else {
                print("It's not the right cell.")
                return
        }
        let whoJoinView = WhoJoinController()

        whoJoinView.thisActivity = myPosts[indexPath.row]
        self.navigationController?.pushViewController(whoJoinView, animated: true)
    }

    @objc func edit(_ sender: UIButton) {
        guard let cell = sender.superview?.superview?.superview?.superview as? MyPostsCell,
            let indexPath = tableView.indexPath(for: cell) else {
                print("It's not the right cell.")
                return
        }
        guard let activityView = UINib.load(nibName: "ActivityController") as? ActivityController else {
            print("ActivityController invalid")
            return
        }
        activityView.myPost = myPosts[indexPath.row]
        self.navigationController?.pushViewController(activityView, animated: true)
    }

    @objc func deleteIt(_ sender: UIButton) {

        guard let cell = sender.superview?.superview?.superview?.superview as? MyPostsCell,
            let indexPath = tableView.indexPath(for: cell) else {
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

        alertView.addButton(NSLocalizedString("NO", comment: "")) {
        }

        alertView.showWarning(NSLocalizedString("Sure to delete it ?", comment: ""), subTitle: "")
    }
}
