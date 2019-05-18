//
//  PersonViewController.swift
//  MyDebts
//
//  Created by Тарас on 3/21/19.
//  Copyright © 2019 Taras. All rights reserved.
//

import UIKit
import CoreData

protocol RightLabelDelegate {
    func updateRightLabel(amount: Int32)
}

class PersonsDebtViewController: UITableViewController, AddNewDebtDelegate  {
    var delegate : RightLabelDelegate?
    var allPersonsDebt = [DebtAdded]()
    var allPersonsDebtAmounts = [Int32]()
    var rightLabelResult : Int32 = 0
    var selectedPerson : Person? {
        didSet {
            loadDebts()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PersonsDebtCell", bundle: nil), forCellReuseIdentifier: "PersonsDebtCell")
        title = selectedPerson?.name
        if let backgroundImage = UIImage(named: "background") {
            self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        rightLabelResult = allPersonsDebtAmounts.reduce(0, +)
        delegate?.updateRightLabel(amount: rightLabelResult)
        switch UIDevice().type {
        case .iPhone5S, .iPhoneSE:
            while title?.count > 10 {
                title?.removeLast()
            }
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8, .iPhoneX, .iPhoneXS:
            while title?.count > 12 {
                title?.removeLast()
            }
        case .iPhone6plus, .iPhone6Splus, .iPhone7plus, .iPhone8plus, .iPhoneXR, .iPhoneXSMax:
            while title?.count > 14 {
                title?.removeLast()
            }
        default:
            break
        }

    }
    
    //MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPersonsDebt.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonsDebtCell", for: indexPath) as! PersonsDebtCell
        cell.commentLabel.text = allPersonsDebt[indexPath.row].comment
        cell.debtLabel.text = "\(allPersonsDebt[indexPath.row].amount)" + " UAH"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, EEEE, MMMM d, yyyy"
        if let date = allPersonsDebt[indexPath.row].dateCreated {
            let dateString = dateFormatter.string(from: date)
            cell.dateLabel.text = dateString
        }
        
        let gradientView = UIView()
        if let backgroundImage = UIImage(named: "background") {
            gradientView.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        cell.selectedBackgroundView = gradientView
        cell.backgroundColor = .clear
        
        if (cell.debtLabel.text?.contains("-") ?? false) {
            cell.gaveLabel.text = "I took"
            cell.gaveLabel.textColor = #colorLiteral(red: 0.9450980392, green: 0.5882352941, blue: 0.1803921569, alpha: 1)
        } else {
            cell.gaveLabel.text = "I gave"
        }
        return cell
    }
    
    //MARK: - TableView Delegate Method

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - SwipeAction
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.context.delete(self.allPersonsDebt[indexPath.row])
            self.rightLabelResult -= self.allPersonsDebtAmounts[indexPath.row]
            self.delegate?.updateRightLabel(amount: self.rightLabelResult)
            self.allPersonsDebt.remove(at: indexPath.row)
            self.allPersonsDebtAmounts.remove(at: indexPath.row)
            self.saveDebt()
            self.tableView.reloadData()
        }
        action.backgroundColor = .red
        action.image = UIImage(named: "delete")
        return action
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewDebt" {
            let destinationVC = segue.destination as! AddNewDebtViewController
            destinationVC.delegate = self
        }
    }
    
    //delegate method
    func add(amount: Int32, comment: String, date: Date, debtor: Bool) {
        let newDebt = DebtAdded(context: context)
        newDebt.comment = comment
        newDebt.debtor = debtor
        newDebt.parentPerson = selectedPerson
        newDebt.dateCreated = date

        if debtor {
            newDebt.amount = amount
        } else {
            newDebt.amount = -amount
        }
        
        allPersonsDebt.append(newDebt)
        allPersonsDebtAmounts.append(newDebt.amount)
        saveDebt()
        
    }
    
    //MARK: - CoreData methods
    
    func saveDebt() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadDebts() {
        let request : NSFetchRequest<DebtAdded> = DebtAdded.fetchRequest()
        if let namePredicate = selectedPerson?.name {
            let predicate = NSPredicate(format: "parentPerson.name MATCHES %@", namePredicate)
            request.predicate = predicate
            do {
                allPersonsDebt = try context.fetch(request)
                for debt in allPersonsDebt {
                    allPersonsDebtAmounts.append(debt.amount)
                }
            } catch {
                print("Error fetching data from context \(error)")
            }
        }
        
    }
}
