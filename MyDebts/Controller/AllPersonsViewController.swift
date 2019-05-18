//
//  ViewController.swift
//  MyDebts
//
//  Created by Тарас on 3/20/19.
//  Copyright © 2019 Taras. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
import SVProgressHUD


class AllPersonsViewController: UITableViewController, CreateNewPersonDelegate, RightLabelDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    var personsArray = [Person]()
    var debtsArray = [Person]()
    var debtsAmounts = [Int32]()
    var debtorsArray = [Person]()
    var debtorsAmounts = [Int32]()
    var currentTitle = ""
    
    var filteredPersons = [Person]()
    
    let rightLabel = UILabel()
    let searchController = UISearchController(searchResultsController: nil)
    
    var rightLabelValue : Int32 = 0
    
    var selectedRow : Int?
    var userChosesPhotoRow : Int?
    var notificationsDatesArray = [Date]()
        
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesSearchBarWhenScrolling = false
        if title == "My debts" {
            rightLabelValue = debtsAmounts.reduce(0, +)
            rightLabel.text = "\(-rightLabelValue)" + " UAH"
        } else {
            rightLabelValue = debtorsAmounts.reduce(0, +)
            rightLabel.text = "\(rightLabelValue)" + " UAH"
        }
    }
    
    override func viewDidLoad() {
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.4078431373, green: 0.4784313725, blue: 0.5098039216, alpha: 1)], for: .normal)
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: " Search", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3994809504)])
        searchController.searchBar.setImage(UIImage(named: "search"), for: UISearchBar.Icon.search, state: .normal)
        
        self.tableView.separatorColor = .white

        self.tableView.rowHeight = 70

        self.searchController.searchBar.setSearchFieldBackgroundImage(UIImage(named: "Rectangle"), for: .normal)
        searchController.searchBar.keyboardAppearance = .dark
        definesPresentationContext = true
        
        if let backgroundImage = UIImage(named: "background") {
            self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: backgroundImage)
            self.navigationController?.toolbar.barTintColor = UIColor(patternImage: backgroundImage)
            self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        
        
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = false
        setupNavBar()
        loadPersons()
        tableView.register(UINib(nibName: "PersonCell", bundle: nil), forCellReuseIdentifier: "PersonCell")
        tableView.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        for person in personsArray {
            if person.amount < 0 && !debtsArray.contains(person) {
                if let index = debtorsArray.index(of: person) {
                    debtorsArray.remove(at: index)
                    debtorsAmounts.remove(at: index)
                }
                debtsArray.append(person)
                debtsAmounts.append(person.amount)
            } else if person.amount > 0 && !debtorsArray.contains(person) {
                if let index = debtsArray.index(of: person) {
                    debtsArray.remove(at: index)
                    debtsAmounts.remove(at: index)
                }
                debtorsArray.append(person)
                debtorsAmounts.append(person.amount)
            }
        }
        tableView.reloadData()
    }
    
    //MARK: - SearchController methods
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        if currentTitle == "My debts" {
            filteredPersons = debtsArray.filter({( debtor : Person) -> Bool in
                guard let debtorToReturn = debtor.name?.lowercased().contains(searchText.lowercased()) else {
                    print("Error filtering persons")
                    return false
                }
                return debtorToReturn
                
            })
        } else {
            filteredPersons = debtorsArray.filter({( debtor : Person) -> Bool in
                guard let debtorToReturn = debtor.name?.lowercased().contains(searchText.lowercased()) else {
                    print("Error filtering persons")
                    return false
                }
                return debtorToReturn
            })
        }
        
        tableView.reloadData()
    }
    
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    //MARK: - Left button and Right label methods
    
    @IBAction func leftButtonPressed(_ sender: UIBarButtonItem) {
        if leftButton.title == "My debts" {
            leftButton.title = "My debtors"
            leftButton.image = UIImage(named: "debtors")
            navigationController?.navigationBar.fadeTransition(0.5)
            self.title = "My debts"
            if let title = self.title {
                currentTitle = title
            }
            rightLabelValue = debtsAmounts.reduce(0, +)
            rightLabel.fadeTransition(0.5)
            rightLabel.text = "\(-rightLabelValue)" + " UAH"
            tableView.reloadData()
            tableView.fadeTransition(0.5)
        } else {
            leftButton.title = "My debts"
            leftButton.image = UIImage(named: "debts")
            navigationController?.navigationBar.fadeTransition(0.5)
            self.title = "My debtors"
            if let title = self.title {
                currentTitle = title
            }
            rightLabelValue = debtorsAmounts.reduce(0, +)
            rightLabel.fadeTransition(0.5)
            rightLabel.text = "\(rightLabelValue)" + " UAH"
            tableView.reloadData()
            tableView.fadeTransition(0.5)
        }
    }
    
    func updateRightLabel(amount: Int32) {
        rightLabelValue = amount
        rightLabel.text =  "\(rightLabelValue)" + " UAH"
        if leftButton.title == "My debts" {
            if let row = selectedRow {
            debtorsArray[row].amount = amount
            debtorsAmounts[row] = amount
            savePerson()
            }
        } else {
            if let row = selectedRow {
            debtsArray[row].amount = amount
            debtsAmounts[row] = amount
            savePerson()
            }
        }
    }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPersons.count
        } else if title == "My debtors"{
            return debtorsArray.count
        } else {
            return debtsArray.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PersonCell
        let person : Person
        cell.avatarImage.layer.borderWidth = 1.0
        cell.avatarImage.layer.masksToBounds = false
        cell.avatarImage.layer.borderColor = UIColor.white.cgColor
        cell.avatarImage.layer.cornerRadius = cell.avatarImage.frame.size.width / 2
        cell.avatarImage.clipsToBounds = true
        
        let gradientView = UIView()
        if let backgroundImage = UIImage(named: "background") {
            gradientView.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        cell.selectedBackgroundView = gradientView
        cell.backgroundColor = .clear
        
        if isFiltering(){
            person = filteredPersons[indexPath.row]
        } else if title == "My debtors" {
            person = debtorsArray[indexPath.row]
        } else {
            person = debtsArray[indexPath.row]
        }
            if let photo = person.avatar  {
                cell.avatarImage.image = UIImage(data: photo)
            } else {
                cell.avatarImage.image = UIImage(named: "noAvatar")
            }
        if let enteredDate = person.timeLeft {
            let timeLeft = Calendar.current.dateComponents([.month, .day], from: Date(), to: enteredDate)
            if let month = timeLeft.month, let day = timeLeft.day {
                if timeLeft.month != 0 {
                    cell.timeLeftLabel.text = "\(month)m \(day)d left"
                } else if day < 0 {
                    cell.timeLeftLabel.text = "\(day)d expired"
                } else {
                    cell.timeLeftLabel.text = "\(day)d left"
                }
            }
        } else {
            cell.timeLeftLabel.text = ""
        }
            cell.nameLabel.text = person.name
        if person.amount < 0 {
            cell.debtLabel.text = "\(-person.amount)" + " UAH"
        } else {
            cell.debtLabel.text = "\(person.amount)" + " UAH"
        }
        
        return cell
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToCurrentPerson", sender: self)
        let indexPath = tableView.indexPathForSelectedRow
        selectedRow = indexPath?.row
        moveAndResizeImage(for: 120)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isFiltering() {
            return false
        } else {
            return true
        }
    }
    
    //MARK: - SwipeActions
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        let timeLeft = timeLeftAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit, timeLeft])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pickAvatar = avatarPickerAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [pickAvatar])
    }

    func avatarPickerAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "New image") { (action, view, completion) in
            let imagePickerController = UIImagePickerController()
            self.userChosesPhotoRow = indexPath.row
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
            self.tableView.reloadData()
            completion(true)
        }
        action.image = UIImage(named: "selectPhoto")
        action.backgroundColor = #colorLiteral(red: 0.02352941176, green: 0.1333333333, blue: 0.168627451, alpha: 1)
        return action
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let row = userChosesPhotoRow {
        if let editedImage = info[.editedImage] as? UIImage {
            if self.leftButton.title == "My debts" {
                self.debtorsArray[row].avatar = editedImage.jpegData(compressionQuality: 0.5)
                self.savePerson()
            } else {
                self.debtsArray[row].avatar = editedImage.jpegData(compressionQuality: 0.5)
                self.savePerson()                    }
            
        } else if let originalImage = info[.originalImage] as? UIImage {
            if self.leftButton.title == "My debts" {
                self.debtorsArray[row].avatar = originalImage.jpegData(compressionQuality: 0.5)
                self.savePerson()
            } else {
                self.debtsArray[row].avatar = originalImage.jpegData(compressionQuality: 0.5)
                self.savePerson()
            }
        }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            if self.leftButton.title == "My debts" {
                self.context.delete(self.debtorsArray[indexPath.row])
                self.rightLabelValue -= self.debtorsAmounts[indexPath.row]
                self.rightLabel.text = "\(self.rightLabelValue)" + " UAH"
                self.debtorsArray.remove(at: indexPath.row)
                self.debtorsAmounts.remove(at: indexPath.row)
                self.savePerson()
                self.tableView.reloadData()
            } else {
                self.context.delete(self.debtsArray[indexPath.row])
                self.rightLabelValue -= self.debtsAmounts[indexPath.row]
                self.rightLabel.text = "\(self.rightLabelValue)" + " UAH"
                self.debtsArray.remove(at: indexPath.row)
                self.debtsAmounts.remove(at: indexPath.row)
                self.savePerson()
                self.tableView.reloadData()
            }
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = #colorLiteral(red: 0.6609612944, green: 0, blue: 0.006187758062, alpha: 1)
        return action
    }
    
    func timeLeftAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "TimeLeft") { (action, view, completion) in
            let alert = UIAlertController(style: .actionSheet, title: "Select the return date")
            alert.setTitle(font: .systemFont(ofSize: 18), color: #colorLiteral(red: 0.05882352941, green: 0.1254901961, blue: 0.1529411765, alpha: 1))
            var userSelectedDate : Date?
            alert.addDatePicker(mode: .date, date: Date(), minimumDate: Date(), maximumDate: nil) { date in
                // action with selected date
                userSelectedDate = date
                userSelectedDate?.hour = 0
                userSelectedDate?.minute = 0
                userSelectedDate?.second = 0
                self.notificationsDatesArray.append(date)
            }
            alert.view.tintColor = .black
            
            let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                if self.leftButton.title == "My debts" {
                    self.debtorsArray[indexPath.row].timeLeft = userSelectedDate
                    self.savePerson()
                    if let nameIdentifier = self.debtorsArray[indexPath.row].name {
                        self.notificationsSetup(selectedDate: userSelectedDate, identifier: nameIdentifier, debtor: self.debtorsArray[indexPath.row].debtor, amount: self.debtorsArray[indexPath.row].amount)
                    }
                    self.tableView.reloadData()
                } else {
                    self.debtsArray[indexPath.row].timeLeft = userSelectedDate
                    self.savePerson()
                    if let nameIdentifier = self.debtsArray[indexPath.row].name {
                        self.notificationsSetup(selectedDate: userSelectedDate, identifier: nameIdentifier, debtor: self.debtsArray[indexPath.row].debtor, amount: self.debtsArray[indexPath.row].amount)
                    }
                    self.tableView.reloadData()
                }
                if userSelectedDate != nil {
                SVProgressHUD.setMinimumDismissTimeInterval(2)
                SVProgressHUD.setDefaultStyle(.dark)
                SVProgressHUD.showSuccess(withStatus: "Notification added")

                }
            }
            
            let action2 = UIAlertAction(title: "Delete date", style: .destructive) { (action:UIAlertAction) in
                let center = UNUserNotificationCenter.current()
                if self.leftButton.title == "My debts" {
                    self.debtorsArray[indexPath.row].timeLeft = nil
                    if let identifier = self.debtorsArray[indexPath.row].name {
                        center.removePendingNotificationRequests(withIdentifiers: [identifier])
                    }
                    self.savePerson()
                    self.tableView.reloadData()
                } else {
                    self.debtsArray[indexPath.row].timeLeft = nil
                    if let identifier = self.debtsArray[indexPath.row].name {
                        center.removePendingNotificationRequests(withIdentifiers: [identifier])
                    }
                    self.savePerson()
                    self.tableView.reloadData()
                }
                completion(true)
            }

            let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                completion(true)
            }
            alert.addAction(action1)
            alert.addAction(action2)
            alert.addAction(action3)
            alert.show()
        }
        action.image = UIImage(named: "timer")
        action.backgroundColor = #colorLiteral(red: 0.2620149786, green: 0.5, blue: 0.2714577391, alpha: 1)
        return action
    }
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            let alert = UIAlertController(title: "Enter the new name", message: "", preferredStyle: .alert)
            alert.setTitle(font: .systemFont(ofSize: 18), color: #colorLiteral(red: 0.05882352941, green: 0.1254901961, blue: 0.1529411765, alpha: 1))
            var userEnteredNewName : String?
            let config: TextField.Config = { textField in
                textField.becomeFirstResponder()
                textField.textColor = .black
                textField.placeholder = "Type something"
                textField.left(image: UIImage(named: "pencil"), color: .black)
                textField.leftViewPadding = 12
                textField.borderWidth = 1
                textField.cornerRadius = 8
                textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
                textField.backgroundColor = nil
                textField.keyboardAppearance = .dark
                textField.keyboardType = .default
                textField.returnKeyType = .done
                textField.action { textField in
                    userEnteredNewName = textField.text
                }
            }
            alert.view.tintColor = #colorLiteral(red: 0.05882352941, green: 0.1254901961, blue: 0.1529411765, alpha: 1)
            alert.addOneTextField(configuration: config)
            let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                if self.leftButton.title == "My debts" && userEnteredNewName != nil {
                    self.debtorsArray[indexPath.row].name = userEnteredNewName
                    self.savePerson()
                    self.tableView.reloadData()
                } else if self.leftButton.title == "My debtors" && userEnteredNewName != nil  {
                    self.debtsArray[indexPath.row].name = userEnteredNewName
                    self.savePerson()
                    self.tableView.reloadData()
                }
                if userEnteredNewName != nil {
                SVProgressHUD.setMinimumDismissTimeInterval(2)
                SVProgressHUD.setDefaultStyle(.dark)
                SVProgressHUD.showSuccess(withStatus: "Name changed")
                completion(true)
                } else {
                    completion(true)
                }
            }
            let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                completion(true)
            }
            alert.addAction(action1)
            alert.addAction(action2)
            alert.show()
        }
        
        action.image = UIImage(named: "edit")
        action.backgroundColor = #colorLiteral(red: 0, green: 0.4042511918, blue: 0.5714274939, alpha: 1)
        return action
    }
    
    //delegate method
    func transfer(name: String, amount: Int32, comment: String, debtor: Bool) {
        let newPerson = Person(context: context)
        let newPersonsDebt = DebtAdded(context: context)
        newPerson.name = name
        newPerson.debtor = debtor
        newPerson.dateCreated = Date()
        newPersonsDebt.parentPerson = newPerson
        newPersonsDebt.comment = comment
        newPersonsDebt.debtor = debtor
        newPersonsDebt.dateCreated = newPerson.dateCreated
        
        if debtor {
            newPerson.amount = amount
            newPersonsDebt.amount = amount
            debtorsArray.append(newPerson)
            debtorsAmounts.append(newPerson.amount)
            rightLabel.text = "\(debtorsAmounts.reduce(0, +))" + " UAH"
        } else {
            newPerson.amount = -amount
            newPersonsDebt.amount = -amount
            debtsArray.append(newPerson)
            debtsAmounts.append(newPerson.amount)
            rightLabel.text = "\(debtsAmounts.reduce(0, +))" + " UAH"
        }
        savePerson()
    }
    
        func setupNavBar() {
        
        self.title = "My debtors"
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9019607843, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9019607843, alpha: 1)]
        if let title = self.title {
            currentTitle = title
        }
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white

        rightLabel.font = UIFont.boldSystemFont(ofSize: 20)
        rightLabel.textColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9019607843, alpha: 1)

        navigationController?.navigationBar.addSubview(rightLabel)
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
    
    //MARK: - Notifications
    
    func notificationsSetup(selectedDate: Date?, identifier: String, debtor: Bool, amount: Int32) {
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        content.title = "Debt return"
        if debtor {
            content.body = "Tomorrow \(identifier) must return to you \(amount)UAH"
        } else {
            content.body = "Tomorrow you must return \(-amount)UAH to \(identifier)"
        }
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        if let date = selectedDate {
        var triggerDate = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: date)
            if let day = triggerDate.day {
                triggerDate.day = day - 1
                triggerDate.hour = 12
                triggerDate.minute = 00
            }
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
            }
            print(triggerDate)
        }
        }
    
    @IBAction func showTotalDifference(_ sender: UIBarButtonItem) {
        let difference = debtsAmounts.reduce(0, +) + debtorsAmounts.reduce(0, +)
        SVProgressHUD.setDefaultStyle(.dark)
        if difference < 0 {
            SVProgressHUD.showInfo(withStatus: "You have a negative balance with a difference of \(-difference) UAH")
        } else {
            SVProgressHUD.showInfo(withStatus: "You have a positive balance with a difference of \(difference) UAH")

        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewPerson" {
            let destinationVC = segue.destination as! CreateNewPersonViewController
            destinationVC.delegate = self
        } else if segue.identifier == "goToCurrentPerson" {
            let destinationVC = segue.destination as! PersonsDebtViewController
            destinationVC.delegate = self
            if let indexPath = tableView.indexPathForSelectedRow {
                if isFiltering() && currentTitle == "My debtors" {
                    destinationVC.selectedPerson = filteredPersons[indexPath.row]
                } else if isFiltering() && currentTitle == "My debts" {
                    destinationVC.selectedPerson = filteredPersons[indexPath.row]
                } else if title == "My debtors" {
                    destinationVC.selectedPerson = debtorsArray[indexPath.row]
                } else {
                    destinationVC.selectedPerson = debtsArray[indexPath.row]
                }
            }
        }
    }
    
    //MARK: - CoreData methods
    
    func savePerson() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadPersons() {
        let request : NSFetchRequest<Person> = Person.fetchRequest()
        do {
            personsArray = try context.fetch(request)
            for person in personsArray {
                if person.amount > 0 {
                    debtorsArray.append(person)
                    debtorsAmounts.append(person.amount)
                } else {
                    debtsArray.append(person)
                    debtsAmounts.append(person.amount)
                }
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        moveAndResizeImage(for: height)
    }
    
    
    struct Const {
        /// Image height/width for Large NavBar state
        static let ImageSizeForLargeState: CGFloat = 40
        /// Margin from right anchor of safe area to right anchor of Image
        static let ImageRightMargin: CGFloat = 16
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let ImageBottomMarginForLargeState: CGFloat = 12
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let ImageBottomMarginForSmallState: CGFloat = 17
        /// Image height/width for Small NavBar state
        static let ImageSizeForSmallState: CGFloat = 32
        /// Height of NavBar for Small state. Usually it's just 44
        static let NavBarHeightSmallState: CGFloat = 44
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let NavBarHeightLargeState: CGFloat = 96.5
    }
    
    //right label behavior when scrolling
    func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()
        
        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState
        
        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()
        
        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()
        
        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        rightLabel.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
}
//animation when updating tableView
extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}

extension AllPersonsViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
        filterContentForSearchText(text)
        }
    }
}

