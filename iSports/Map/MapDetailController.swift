//
//  MapDetailController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/25.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class MapDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    
    var selectedPlaceActivities = [Activity]()
    
    var mainViewController: MapController?
    
    var headerView = UITableViewHeaderFooterView()
    
    var selectedPlace: Place? {
        
        didSet {
            FirebaseProvider.shared.getPlaceAllActivities(place: selectedPlace, completion: { (results, error) in
                self.selectedPlaceActivities = results!
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0, y: 400, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedPlaceActivities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListsCell
        let result = selectedPlaceActivities[indexPath.row]
            cell.titleLabel.text = result.name
            cell.timeLabel.text = result.time
            cell.placeLabel.text = result.place.placeName
            cell.numLabel.text = "\(result.number) / \(result.allNumber)"
            cell.joinButton.isHidden = true

        switch result.type {
        case "羽球": cell.imagePlaced.image = UIImage(named: "badminton")!
        case "棒球": cell.imagePlaced.image = UIImage(named: "baseball")!
        case "籃球": cell.imagePlaced.image = UIImage(named: "basketball")!
        case "排球": cell.imagePlaced.image = UIImage(named: "volleyball")!
        case "網球": cell.imagePlaced.image = UIImage(named: "tennis")!
        case "足球": cell.imagePlaced.image = UIImage(named: "soccer")!
        default:
            return cell
        }
        
        switch result.level {
        case .A: cell.levelImage.image = UIImage(named: "labelA")
        case .B: cell.levelImage.image = UIImage(named: "labelB")
        case .C: cell.levelImage.image = UIImage(named: "labelC")
        case .D: cell.levelImage.image = UIImage(named: "labelD")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton()
        let downArrowIcon = UIImage(named: "icon-down-arrow")?.withRenderingMode(.alwaysTemplate)
        button.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: 32)
        headerView.addSubview(button)
        button.backgroundColor = myBlack
        button.setImage(downArrowIcon, for: .normal)
        button.contentMode = .scaleAspectFit
        button.imageView?.tintColor = myWhite
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return headerView
    }
    
    func setupTableCell() {
        let nib = UINib(nibName: "ListsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    @objc func close() {
        self.view.removeFromSuperview()
    }

}
