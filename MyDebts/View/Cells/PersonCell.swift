//
//  CustomCell.swift
//  MyDebts
//
//  Created by Тарас on 3/20/19.
//  Copyright © 2019 Taras. All rights reserved.
//

import UIKit

class PersonCell: UITableViewCell {

    
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var debtLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var noDebtsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    

    
}
