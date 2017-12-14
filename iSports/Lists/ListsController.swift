//
//  TableViewController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase

class ListsController: UITableViewController {
    
    var results = [Preference]()
    
    var isSearch: Bool = false
//    @IBAction func searchAuthor() {
//        searchResults = [Preference]()
//        let ref = Database.database().reference().child("activities").queryOrdered(byChild: "type").queryEqual(toValue: "羽球")
//        ref.observe(.value, with: { (snapshot: DataSnapshot) in
//            guard let snapShotData = snapshot.value as? [String: AnyObject] else { return }
//            for (activitiesId, activitiesData) in snapShotData {
//                let id = activitiesId
//                guard let type = activitiesData["type"] as? Sportstype else { return }
//                guard let level = activitiesData["level"] as? Level else { return }
//                guard let place = activitiesData["place"] as? String else { return }
//                guard let time = activitiesData["time"] as? String else { return }
//                let activities = Preference(type: type, level: level, place: place, time: time)
//                self.searchResults.append(activities)
//            }
//            print(self.searchResults)
//            self.tableView.reloadData()
//        })
//
//
//
//
//    }
//    lazy var searchButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 1)
//        button.setTitle("Search", for: .normal)
////        button.translatesAutoresizingMaskIntoConstraints = false
//        button.frame = CGRect(x: 300, y: 0, width: 50, height: 50)
////        button.setTitleColor(UIColor.white, for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//
//        button.addTarget(self, action: #selector(searchAuthor(type:)), for: .touchUpInside)
//        return button
//    }()
    
//    lazy var searchTextField: UITextField = {
//        let tf = UITextField()
//        tf.backgroundColor = UIColor.white
//        tf.autocapitalizationType = .none
//        tf.placeholder = "🔍 Author Name"
//        tf.textAlignment = .center
//        if let tfWitdth = self.navigationController?.navigationBar.frame.width,
//            let tfHeight = self.navigationController?.navigationBar.frame.height {
//            tf.frame = CGRect(x: 0, y: 0, width: tfWitdth * 0.6, height: tfHeight * 0.8)
//        } else {
//            tf.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
//        }
//        tf.delegate = self
//        return tf
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableCell()
        navigationItem.title = "title"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "search", style: .plain, target: self, action: #selector(searchAuthor))
        tableView.delegate = self
        tableView.dataSource = self
        
        fetch()
        
        
        
        

       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTableCell() {
        let nib = UINib(
            nibName: "ListsCell",
            bundle: nil
        )
        
        tableView.register(
            nib,
            forCellReuseIdentifier: "cell"
        )
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListsCell 
            print(self.results)
            cell.titleLabel.text = results[indexPath.row].id
            cell.timeLabel.text = results[indexPath.row].time
            cell.levelLabel.text = results[indexPath.row].level.rawValue
            cell.typeLabel.text = results[indexPath.row].type.rawValue
            
            return cell
        

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    @objc func searchAuthor() {
        results = [Preference]()
        let ref = Database.database().reference().child("activities").queryOrdered(byChild: "type").queryEqual(toValue: "羽球").queryOrdered(byChild: "time").queryEqual(toValue: "星期一")
        ref.observe(.value, with: { (snapshot: DataSnapshot) in
            guard let snapShotData = snapshot.value as? [String: AnyObject] else { return }
            for (activitiesId, activitiesData) in snapShotData {
                let id = activitiesId
                guard let type = activitiesData["type"] as? Sportstype else { return }
                guard let level = activitiesData["level"] as? Level else { return }
                guard let place = activitiesData["place"] as? String else { return }
                guard let time = activitiesData["time"] as? String else { return }
                let activities = Preference(id: id,type: type, level: level, place: place, time: time)
                self.results.append(activities)
            }
            print(self.results)
            self.tableView.reloadData()
        })
    }

    

  

}

//extension ListsController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.isSearch = true
//        print(self.isSearch)
//        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        searchTextField.addSubview(activityIndicator)
//        activityIndicator.frame = searchTextField.bounds
//        activityIndicator.startAnimating()
//        
//        let searchText = searchTextField.text ?? ""
//        self.searchAuthor(type: searchText)
//        
//        searchTextField.text = nil
//        searchTextField.resignFirstResponder()
//        activityIndicator.stopAnimating()
//        return true
//    }
//}

extension ListsController {
    
    func fetch() {
        
        Database.database().reference().child("activities").observe(.value) { (snapshot: DataSnapshot) in
            self.results = [Preference]()
            print(snapshot)
            if let objects = snapshot.value as? [String: AnyObject] {
                for (id, data) in objects {
                    let id = id
                    if
                        let type = data["type"] as? String,
                        let time = data["time"] as? String,
                        let place = data["place"] as? String,
                        let level = data["level"] as? String {
                        self.results.append(Preference(id: id, type: Sportstype(rawValue: type)!, level: Level(rawValue: level)!, place: place, time: time))
                        }
                }
                self.tableView.reloadData()
            }
        }
    }
}

        

    
    
    
    

