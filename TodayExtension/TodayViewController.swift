//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Тарас on 4/17/19.
//  Copyright © 2019 Taras. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UITableViewController, NCWidgetProviding {
    
    var allPersons = [Person]()
    var personsTimeLeft = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TodayExtensionTableViewCell", bundle: nil), forCellReuseIdentifier: "todayCell")
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        loadPersons()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 220)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsToReturn = 0
        personsTimeLeft.count == 0 ? (numberOfRowsToReturn = 1) : (numberOfRowsToReturn = personsTimeLeft.count)
        return numberOfRowsToReturn
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todayCell", for: indexPath) as! TodayExtensionTableViewCell
        
        if personsTimeLeft.count == 0 {
            cell.amountLabel.text = ""
            cell.dateLabel.text = ""
            cell.NameLabel.text = ""
            cell.NoDatesLabel.isHidden = false
        } else {
            let person = personsTimeLeft[indexPath.row]
            cell.avatarImageView.layer.masksToBounds = false
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2
            cell.avatarImageView.clipsToBounds = true
        if let photo = person.avatar  {
            cell.avatarImageView.image = UIImage(data: photo)
        } else {
            cell.avatarImageView.image = UIImage(named: "noAvatar")
        }
            cell.NameLabel.text = personsTimeLeft[indexPath.row].name
        if person.amount < 0 {
            cell.amountLabel.text = "\(person.amount)" + " UAH"
            cell.amountLabel.textColor = #colorLiteral(red: 0.8727874389, green: 0, blue: 0.008170822644, alpha: 1)
        } else {
            cell.amountLabel.text = "+\(person.amount)" + " UAH"
            cell.amountLabel.textColor = #colorLiteral(red: 0, green: 0.537254902, blue: 0.3215686275, alpha: 1)
        }
        if let enteredDate = person.timeLeft {
            let timeLeft = Calendar.current.dateComponents([.month, .day], from: Date(), to: enteredDate)
            if let month = timeLeft.month, let day = timeLeft.day {
                if timeLeft.month != 0 {
                    cell.dateLabel.text = "\(month)m \(day)d left"
                } else if day < 0 {
                    cell.dateLabel.text = "\(day)d expired"
                } else {
                    cell.dateLabel.text = "\(day)d left"
                }
            }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("TAPPED")
        tableView.deselectRow(at: indexPath, animated: true)
        let url = URL(string: "MyDebts://")!
        self.extensionContext?.open(url, completionHandler: { (success) in
            if (!success) {
                print("error: failed to open app from Today Extension")
            }
        })
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
    
        let container = NSCustomPersistentContainer(name: "MyDebts")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func loadPersons() {
        let request : NSFetchRequest<Person> = Person.fetchRequest()
        let context = persistentContainer.viewContext
        do {
            allPersons = try context.fetch(request)
            for person in allPersons {
                if person.timeLeft != nil {
                    personsTimeLeft.append(person)
                }
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }

}

