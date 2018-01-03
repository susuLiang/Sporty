//
//  WhoJoinController.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/2.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit
import Nuke

class WhoJoinController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    
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
            collectionView.reloadData()
        }
    }
  

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Your Partners"
        view.backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 175, height: 209)
        collectionView = UICollectionView(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "WhoJoinCell", bundle: nil) , forCellWithReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return joinUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? WhoJoinCell else {
            fatalError()
        }
        let joinUser = joinUsers[indexPath.row]
        cell.userName.text = joinUser.name
        DispatchQueue.main.async {
            // todo: !
            Nuke.loadImage(with: URL(string: joinUser.urlString!)!, into: cell.userPhoto)

        }
        return cell
    }
    
//    func setupTableCell() {
//        let nib = UINib(nibName: "WhoJoinCell", bundle: nil)
//        collectionView.register(nib, forCellReuseIdentifier: "cell")
//    }

//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return joinUsers.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WhoJoinCell else {
//            fatalError("Invalid profile cell") }
//        let joinUser = joinUsers[indexPath.row]
//        cell.userName.text = joinUser.name
//        DispatchQueue.main.async {
//            // todo: !
//            Nuke.loadImage(with: URL(string: joinUser.urlString!)!, into: cell.userPhoto)
//
//        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
    
}
