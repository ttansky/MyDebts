//
//  ViewController.swift
//  MyDebts
//
//  Created by Тарас on 3/20/19.
//  Copyright © 2019 Taras. All rights reserved.
//

import UIKit

class AllDebtsViewController: UITableViewController {

    let tempArray = ["Taras", "Maks", "Olya", "Nikish"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        
    }
    
    //MARK:- TableView Datasource Methods
    


    
    
    func setupNavBar() {
        
        self.title = "My debtors"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false
        
        let searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        
        let rightLabel = UILabel()
        rightLabel.font = UIFont.systemFont(ofSize: 20)
        rightLabel.text = "2056" + " UAH"
        rightLabel.textColor = .black
        
        navigationController?.navigationBar.addSubview(rightLabel)
        rightLabel.tag = 1
        rightLabel.frame = CGRect(x: self.view.frame.width, y: 0, width: 120, height: 20)
        
        let targetView = self.navigationController?.navigationBar
        
        let trailingContraint = NSLayoutConstraint(item: rightLabel, attribute:
            .trailingMargin, relatedBy: .equal, toItem: targetView,
                             attribute: .trailingMargin, multiplier: 1.0, constant: -16)
        let bottomConstraint = NSLayoutConstraint(item: rightLabel, attribute: .bottom, relatedBy: .equal,
                                                  toItem: targetView, attribute: .bottom, multiplier: 1.0, constant: -12)
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([trailingContraint, bottomConstraint])
    }

}

