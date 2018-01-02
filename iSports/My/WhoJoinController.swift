//
//  WhoJoinController.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/2.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit
import Nuke

class WhoJoinController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    
    var thisActivity: Activity? {
        didSet{
            FirebaseProvider.shared.getWhoJoin(activityId: (thisActivity?.id)!, completion: {(users ,error) in
                if error == nil, let users = users {
                    self.joinUsers = users
                }
            })
        }
    }
    
    var joinUsers: [UserSetting] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        tableView.delegate = self
        tableView.dataSource = self
        setupTableCell()
        view.addSubview(tableView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableCell() {
        let nib = UINib(nibName: "WhoJoinCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WhoJoinCell else {
            fatalError("Invalid profile cell") }
        let joinUser = joinUsers[indexPath.row]
        cell.userName.text = joinUser.name
        DispatchQueue.main.async {
            // todo: !
            Nuke.loadImage(with: URL(string: joinUser.urlString!)!, into: cell.userPhoto)

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
