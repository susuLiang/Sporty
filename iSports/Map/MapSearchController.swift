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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0, y: 0, width: 150, height: UIScreen.main.bounds.height)
        
        tableView.frame = CGRect(x: 0, y: 0, width: 150, height: UIScreen.main.bounds.height)
        
        tableView.alpha = 0.9
        
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
        cell.typeButton.setTitle(typeArray[indexPath.row], for: .normal)

        return cell
    }
    
}
