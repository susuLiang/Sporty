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
        
        view.backgroundColor = .clear
                
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
        
        cell.titleLabel.text = result.name
        cell.timeLabel.text = result.time
        cell.placeLabel.text = result.place.placeName
        cell.numLabel.text = "\(result.number) / \(result.allNumber)"
        switch result.level {
        case .A: cell.levelImage.image = UIImage(named: "labelA")
        case .B: cell.levelImage.image = UIImage(named: "labelB")
        case .C: cell.levelImage.image = UIImage(named: "labelC")
        case .D: cell.levelImage.image = UIImage(named: "labelD")
        }
        cell.joinButton.setImage(UIImage(named: "icon-quit"), for: .normal)
        cell.joinButton.tintColor = myRed
        cell.joinButton.addTarget(self, action: #selector(deleteIt), for: .touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
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
    
    @objc func deleteIt(_ sender: UIButton) {
        
        guard let cell = sender.superview?.superview as? ListsCell,
        
            let indexPath = tableView.indexPath(for: cell) else {
                print("It's not a cell.")
                return
        }
        
        let alertController = UIAlertController(title: "Quit now", message: "Be sure to quit?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Sure", style: .default, handler: { (action) in
            
            let uid = self.keyUid[indexPath.row]

            let ref = Database.database().reference()
            
            ref.child("user_joinId").child(uid).removeValue()
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}
