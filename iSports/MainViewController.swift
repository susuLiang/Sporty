//
//  MainViewController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/14.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    var searchResults = [Preference]()
     @IBOutlet weak var searText: UITextField!

    @IBOutlet weak var numLabel: UILabel!
    
    @IBAction func search(_ sender: Any) {
        searchResults = [Preference]()
        let ref = Database.database().reference().child("activities").queryOrdered(byChild: "type").queryEqual(toValue: "羽球")
        ref.observe(.value, with: { (snapshot: DataSnapshot) in
            print(snapshot.value)
            guard let snapShotData = snapshot.value as? [String: AnyObject] else { return }
            for (activitiesId, activitiesData) in snapShotData {
                let id = activitiesId
                guard let type = activitiesData["type"] as? Sportstype else { return }
                guard let level = activitiesData["level"] as? Level else { return }
                guard let place = activitiesData["place"] as? String else { return }
                guard let time = activitiesData["time"] as? String else { return }
                let activities = Preference(id: id, type: type, level: level, place: place, time: time)
                self.searchResults.append(activities)
            }
            print(self.searchResults)
            self.viewDidLoad()
//            self.tableView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numLabel.text = String(searchResults.count)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
