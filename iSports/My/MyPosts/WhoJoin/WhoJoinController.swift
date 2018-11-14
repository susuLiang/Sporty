//
//  WhoJoinController.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/2.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit
import Nuke
import NVActivityIndicatorView
import Crashlytics

class WhoJoinController: UIViewController {

    var loadingIndicator = LoadingIndicator()

    var collectionView: UICollectionView!

    var thisActivity: Activity = Activity() {
        didSet {
            loadingIndicator.start()
            FirebaseProvider.shared.getWhoJoin(activityId: thisActivity.id, completion: {(users, error) in
                if error == nil, let users = users {
                    self.joinUsers = users
                }
                DispatchQueue.main.async {
                    self.loadingIndicator.stop()
                    self.collectionView.reloadData()
                }
            })
        }
    }

    var joinUsers: [UserSetting] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Your Partners", comment: "")
        view.backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width / 2 - 30), height: 209)
        collectionView = UICollectionView(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibWithCellClass: WhoJoinCell.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension WhoJoinController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return joinUsers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: WhoJoinCell.self, for: indexPath)
        let joinUser = joinUsers[indexPath.row]
        cell.userName.text = joinUser.name
        if let url = joinUser.urlString {
            DispatchQueue.main.async {
                Nuke.loadImage(with: URL(string: url)!, into: cell.userPhoto) { response, _ in
                    cell.userPhoto.image = response.value
                }
            }
        }
        return cell
    }

}
