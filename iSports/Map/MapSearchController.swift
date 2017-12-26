//
//  MapSearchController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/25.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class MapSearchController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    
    var mainViewController: MapController?
    
    var selectedType: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0, y: 0, width: 150, height: UIScreen.main.bounds.height)
        
        view.backgroundColor = myWhite
        
        tableView.frame = CGRect(x: 0, y: 0, width: 150, height: UIScreen.main.bounds.height - 30)
        
        tableView.alpha = 0.95
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        setupTableCell()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        func setupTableCell() {
        let nib = UINib(nibName: "MapSearchCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "mapSearchCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapSearchCell", for: indexPath) as! MapSearchCell
        cell.typeLabel.text = typeArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedType = typeArray[indexPath.row]
        mainViewController?.selectedType = self.selectedType
        self.view.removeFromSuperview()
    }
}
