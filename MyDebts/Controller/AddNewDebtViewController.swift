//
//  AddNewDebtViewController.swift
//  MyDebts
//
//  Created by Тарас on 3/26/19.
//  Copyright © 2019 Taras. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol AddNewDebtDelegate {
    func add(amount: Int32, comment: String, date: Date, debtor: Bool)
}

class AddNewDebtViewController: UIViewController {
    
    var delegate : AddNewDebtDelegate?
    var isDebtor: Bool = true
    
    @IBOutlet weak var segmentedChoice: UISegmentedControl!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        SVProgressHUD.setDefaultStyle(.dark)
        segmentedChoice.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)], for: .normal)
        
        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillShowNotification, object: nil, queue: nil) { (nc) in
            self.view.frame.origin.y = -125
        }
        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillHideNotification, object: nil, queue: nil) { (nc) in
            self.view.frame.origin.y = 0.0
        }
        
        _ = CreateNewPersonViewController().makeRoundedCorners(views: [amountTextField, commentTextField, segmentedChoice, cancelButton, saveButton])
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Actions
    @IBAction func segmentedPressed(_ sender: UISegmentedControl) {
        if segmentedChoice.selectedSegmentIndex == 0 {
            isDebtor = true
        } else if segmentedChoice.selectedSegmentIndex == 1 {
            isDebtor = false
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        
        if let enteredAmount = Int32(amountTextField.text!), let enteredComment = commentTextField.text, enteredComment != "", segmentedChoice.selectedSegmentIndex != -1 {
            
            let dateCreated = Date()
            
            delegate?.add(amount: enteredAmount, comment: enteredComment, date: dateCreated, debtor: isDebtor )
        
            self.dismiss(animated: true, completion: nil)
            SVProgressHUD.showSuccess(withStatus: "Done!")
        } else {
            SVProgressHUD.showError(withStatus: "Please enter full information")
        }


    }
    
}
