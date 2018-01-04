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
        view.backgroundColor = .white
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
        let nib = UINib(nibName: "MyPostsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myPosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyPostsCell else { fatalError() }

        let result = myPosts[indexPath.row]
        cell.nameLabel.text = result.name

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
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func getPosts() {
        FirebaseProvider.shared.getPosts(childKind: "postId", completion: { (posts, keyUid, error) in
            if error == nil {
                self.myPosts = posts!
                self.keyUid = keyUid!
                self.tableView.reloadData()
            }
        })

    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
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
        activityView.joinButton.isHidden = true
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

        alertView.addButton("SURE", action: {
            let uid = self.keyUid[indexPath.row]
            let postId = self.myPosts[indexPath.row].id
            let ref = Database.database().reference()
            self.keyUid.remove(at: indexPath.row)
            ref.child("activities").child(postId).removeValue()
            ref.child("user_postId").child(uid).removeValue()
        })

        alertView.addButton("NO") {
        }

        alertView.showWarning("Sure to delete it ?", subTitle: "")
    }
}
