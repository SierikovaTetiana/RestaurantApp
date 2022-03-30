//
//  CheckOutViewController.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 21.11.2021.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import PhoneNumberKit
import GooglePlaces
import NotificationBannerSwift

class CheckOutViewController: UIViewController {
    
    @IBAction func orderButtonTapped(_ sender: UIButton) {
        orderButtonTappedAction(sender: sender)
    }
    
    @IBOutlet weak var checkOutTable: UITableView!
    
    var cartData = [CartData]()
    private var totalOrder = [String: String]()
    private var totalSumCount = [String: Int]()
    private let db = Firestore.firestore()
    private let phoneNumberKit = PhoneNumberKit()
    private let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
    private var orderData = [OrderPersonData(takeAway: true, deliveryAddress: "", name: "", phone: "", comment: "", time: Date(timeIntervalSince1970: 0), userID: String(Auth.auth().currentUser!.uid))]
    private var orderTime = Date(timeIntervalSince1970: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scoresRef = Database.database().reference()
        scoresRef.keepSynced(true)
        checkOutTable.delegate = self
        checkOutTable.dataSource = self
        checkOutTable.register(UINib(nibName: "order0RowTableViewCell", bundle: nil), forCellReuseIdentifier: "order0RowTableViewCell")
        checkOutTable.register(UINib(nibName: "order1RowTableViewCell", bundle: nil), forCellReuseIdentifier: "order1RowTableViewCell")
        getUserData()
        countTotalSum()
    }
    
    private func countTotalSum() {
        for item in cartData {
            totalSumCount[item.dishTitle] = item.price
        }
        totalOrder["totalPrice"] = String(totalSumCount.values.reduce(0, +))
    }

    private func getUserData() {
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let firstData = document.data() {
                    if let username = firstData["username"], let phone = firstData["phoneNumber"] {
                        for order in self.orderData {
                            order.phone = "\(phone)"
                            order.name = "\(username)"
                        }
                    }
                    if let orders = firstData["order"] as? [String: String] {
                        for (key, value) in orders {
                            switch key {
                            case "Имя":
                                for order in self.orderData {
                                    order.name = "\(value)"
                                }
                            case "Номер телефона":
                                for order in self.orderData {
                                    order.phone = "\(value)"
                                }
                            case "Комментарий к заказу":
                                for order in self.orderData {
                                    order.comment = "\(value)"
                                }
                            case "Доставка":
                                if value == "Да" {
                                    for order in self.orderData {
                                        order.takeAway = true
                                    }
                                } else {
                                    for order in self.orderData {
                                        order.takeAway = false
                                    }
                                }
                            case "Приготовить к":
                                if #available(iOS 15.0, *) {
                                    let strategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)T\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)\(timeZone: .iso8601(.short))", timeZone: .current)
                                    if let date = try? Date(value, strategy: strategy) {
                                        for order in self.orderData {
                                            order.time = date
                                        }
                                    }
                                }
                            case "Адрес доставки":
                                for order in self.orderData {
                                    order.deliveryAddress = "\(value)"
                                }
                            default:
                                return
                            }
                        }
                    }
                    self.checkOutTable.reloadData()
                }
            }
        }
    }
    
    private func uploadUserOrder(prop: String, value: String) {
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.docRef.updateData((["order.\(prop)": value]), completion: { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                })
            }
        }
    }
    
    private func checkCorrectUserEnter() -> Bool {
        if orderData[0].name == "" {
            let alert = UIAlertController(title: "Привет, давай знакомиться!:)", message: "Как Вас зовут?", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Введите своё имя"
            }
            alert.addAction(UIAlertAction(title: "Готово", style: .default, handler: { [weak alert] (_) in
                if let textField = alert?.textFields?[0] {
                    for order in self.orderData {
                        if let textFieldText = textField.text {
                            order.name = textFieldText
                        }
                    }
                    if let name = textField.text {
                        self.uploadUserOrder(prop: "Имя", value: name)
                    }
                    self.checkOutTable.reloadData()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        } else if (orderData[0].takeAway == true && orderData[0].deliveryAddress == "") {
            let alert = UIAlertController(title: "Укажите адрес доставки", message: "или выберете 'Самовывоз', если хотите забрать заказ из ресторана", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Готово", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        do {
            let phoneNum = try self.phoneNumberKit.parse(self.orderData[0].phone)
            let num = self.phoneNumberKit.format(phoneNum, toType: .e164)
            for order in self.orderData {
                order.phone = num
            }
            self.uploadUserOrder(prop: "Номер телефона", value: num)
            self.checkOutTable.reloadData()
            
            if orderData[0].name != "" && !(orderData[0].takeAway == true && orderData[0].deliveryAddress == "") && !num.isEmpty {
                return true
            }
            
        }
        catch {
            let alert = UIAlertController(title: "Укажите свой номер телефона, чтоб мы смогли с Вами связаться", message: "Введите номер телефона в формате +380501234567", preferredStyle: UIAlertController.Style.alert)
            alert.addTextField { (textField) in
                textField.placeholder = "+380501234567"
            }
            alert.addAction(UIAlertAction(title: "Готово", style: .default, handler: { [weak alert] (_) in
                if let textField = alert?.textFields?[0] {
                    for order in self.orderData {
                        if let textFieldText = textField.text {
                            order.phone = textFieldText
                        }
                    }
                    self.checkOutTable.reloadData()
                }
            }))
            self.present(alert, animated: true, completion: nil)
            print("Generic parser error")
        }
        return false
    }
    
    private func orderButtonTappedAction(sender: UIButton) {
        if checkCorrectUserEnter() == true {
            if let user = Auth.auth().currentUser?.uid {
                for order in orderData {
                    if order.time == Date(timeIntervalSince1970: 0) {
                        db.collection("orders").document(user).setData([
                            "user": order.name,
                            "phoneNumber": order.phone,
                            "delivery": order.takeAway,
                            "deliveryAddress": order.deliveryAddress,
                            "comment": order.comment,
                            "readyTo": "как можно скорее",
                            "userID": order.userID
                        ])
                        { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                                let banner = FloatingNotificationBanner(title: "Заказ не был отправлен", subtitle: "Попробуйте повторить снова. Ошибка: \(err)", style: .danger)
                                banner.show()
                            } else {
                                print("Document successfully written!")
                                let banner = FloatingNotificationBanner(title: "Заказ успешно отправлен", subtitle: "Ждите информацию про готовность", style: .success)
                                banner.show()
                            }
                        }
                    } else {
                        db.collection("orders").document(user).setData([
                            "user": order.name,
                            "phoneNumber": order.phone,
                            "delivery": order.takeAway,
                            "deliveryAddress": order.deliveryAddress,
                            "comment": order.comment,
                            "readyTo": order.time,
                            "userID": order.userID
                        ])
                        { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                                let banner = FloatingNotificationBanner(title: "Заказ не был отправлен", subtitle: "Попробуйте повторить снова. Ошибка: \(err)", style: .danger)
                                banner.show()
                            } else {
                                print("Document successfully written!")
                                let banner = FloatingNotificationBanner(title: "Заказ успешно отправлен", subtitle: "Ждите информацию про готовность", style: .success)
                                banner.show()
                            }
                        }
                    }
                }
                for dish in cartData {
                    totalOrder["cart.\(dish.dishTitle)"] = "\(dish.count)"
                }
                db.collection("orders").document(user).updateData(totalOrder) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.navigationItem.setHidesBackButton(true, animated: true)
                        self.title = "Спасибо, Ваш заказ принят"
                        self.navigationController?.navigationBar.barTintColor = .green
                        self.docRef.updateData([
                            "cart": FieldValue.delete(),
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "CheckOutToMain", sender: self)
                }
            }
        }
    }
}

extension CheckOutViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel()
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 19)
        title.textColor = UIColor(named: "darkGreen")
        if section == 0 {
            title.text = "Как Вы хотите получить свой заказ?"
            return title
        } else if section == 1 {
            title.text = "Персональные данные"
            return title
        } else if section == 2 {
            title.text = "Комментарий к заказу:"
            return title
        } else if section == 3 {
            title.text = "Приготовить к:"
            return title
        } else {
            title.text = "На данный момент возможна оплата с помощью терминала или наличными при получении заказа"
            title.numberOfLines = 0
            title.textAlignment = .center
            return title
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 {
            return 1
        } else if indexPath.section == 1 {
            if orderData[0].takeAway == false {
                return 100
            } else {
                return 150
            }
        } else if indexPath.section == 3 {
            return 50
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "order0RowTableViewCell", for: indexPath) as? order0RowTableViewCell else { return UITableViewCell() }
            if orderData[0].takeAway != false {
                cell.takeAway.selectedSegmentIndex = 1
            } else {
                cell.takeAway.selectedSegmentIndex = 0
            }
            cell.takeAway.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
            cell.takeAway.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .touchUpInside)
            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "order1RowTableViewCell", for: indexPath) as? order1RowTableViewCell else { return UITableViewCell() }
            cell.orderPersonalName.shouldResignOnTouchOutsideMode = .enabled
            cell.orderPersonalPhone.shouldResignOnTouchOutsideMode = .enabled
            cell.orderPersonalAddress.shouldResignOnTouchOutsideMode = .enabled
            if orderData[0].name != "" {
                cell.orderPersonalName.text = orderData[0].name
            } else {
                cell.orderPersonalName.placeholder = "Имя"
            }
            cell.orderPersonalName.addTarget(self, action: #selector(orderPersonalNameDidChange(_:)), for: .allEditingEvents)
            if orderData[0].phone != "" {
                cell.orderPersonalPhone.text = orderData[0].phone
            } else {
                cell.orderPersonalPhone.placeholder = "Номер телефона"
            }
            cell.orderPersonalPhone.addTarget(self, action: #selector(orderPersonalPhoneDidChange(_:)), for: .allEditingEvents)
            if orderData[0].takeAway == false {
                cell.addressStackView.isHidden = true
            } else {
                cell.addressStackView.isHidden = false
                if orderData[0].deliveryAddress != "" {
                    cell.orderPersonalAddress.text = orderData[0].deliveryAddress
                } else {
                    cell.orderPersonalAddress.placeholder = "Адрес доставки"
                }
                cell.orderPersonalAddress.addTarget(self, action: #selector(orderPersonalAddressDidChange(_:)), for: .allEditingEvents)
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = UITableViewCell()
            let comment = IQTextView()
            comment.delegate = self
            comment.shouldResignOnTouchOutsideMode = .enabled
            comment.translatesAutoresizingMaskIntoConstraints = false
            if orderData[0].comment != "" {
                comment.text = orderData[0].comment
            } else {
                comment.placeholder = "Ваши пожелания"
            }
            comment.keyboardType = UIKeyboardType.default
            comment.returnKeyType = UIReturnKeyType.done
            comment.autocorrectionType = UITextAutocorrectionType.no
            comment.font = UIFont.systemFont(ofSize: 14)
            comment.isUserInteractionEnabled = true
            cell.contentView.addSubview(comment)
            NSLayoutConstraint.activate([
                comment.leadingAnchor.constraint(equalTo:cell.contentView.leadingAnchor),
                comment.trailingAnchor.constraint(equalTo:cell.contentView.trailingAnchor),
                comment.topAnchor.constraint(equalTo:cell.contentView.topAnchor),
                comment.bottomAnchor.constraint(equalTo:cell.contentView.bottomAnchor)
            ])
            return cell
        } else if indexPath.section == 3 {
            let cell = UITableViewCell()
            let titleLabel:UILabel = {
                let label = UILabel(frame: CGRect(x:0, y: 0, width: UIScreen.main.bounds.width , height: 40))
                label.textAlignment = .left
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
                return label
            }()
            let dataPick = UIDatePicker()
            if indexPath.row == 0 {
                for item in orderData {
                    if item.time == Date(timeIntervalSince1970: 0) {
                        cell.accessoryType = .checkmark
                    }
                }
                titleLabel.text = "Как можно скорее"
                cell.contentView.addSubview(titleLabel)
                NSLayoutConstraint.activate([
                    titleLabel.leadingAnchor.constraint(equalTo:cell.contentView.leadingAnchor),
                    titleLabel.trailingAnchor.constraint(equalTo:cell.contentView.trailingAnchor),
                    titleLabel.topAnchor.constraint(equalTo:cell.contentView.topAnchor),
                    titleLabel.bottomAnchor.constraint(equalTo:cell.contentView.bottomAnchor)
                ])
            } else {
                for item in orderData {
                    if item.time != Date(timeIntervalSince1970: 0) {
                        cell.accessoryType = .checkmark
                        dataPick.setDate(item.time, animated: true)
                    } else {
                        if #available(iOS 15, *) {
                            dataPick.setDate(Date.now, animated: true)
                        } else {
                            dataPick.setDate(item.time, animated: true)
                        }
                    }
                }
                dataPick.addTarget(self, action: #selector(dataPickValueChanged(_:)), for: .valueChanged)
                cell.contentView.addSubview(dataPick)
            }
            return cell
        } else {
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            if indexPath.row == 0 {
                for order in orderData {
                    order.time = Date(timeIntervalSince1970: 0)
                }
            } else {
                for order in orderData {
                    order.time = orderTime
                }
            }
            uploadUserOrder(prop: "Приготовить к", value: "как можно скорее")
            tableView.reloadData()
        }
    }
    
    @objc private func dataPickValueChanged (_ sender: UIDatePicker) {
        for order in orderData {
            order.time = sender.date
        }
        uploadUserOrder(prop: "Приготовить к", value: "\(sender.date)")
        checkOutTable.reloadData()
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            for order in orderData {
                order.takeAway = false
            }
            uploadUserOrder(prop: "Доставка", value: "Нет")
        } else {
            for order in orderData {
                order.takeAway = true
            }
            uploadUserOrder(prop: "Доставка", value: "Да")
        }
        checkOutTable.reloadData()
    }
    
    @objc private func orderPersonalNameDidChange (_ sender: UITextField) {
        if let person = sender.text {
            for order in orderData {
                order.name = person
            }
            if sender.text != "" {
                uploadUserOrder(prop: "Имя", value: person)
            }
        }
    }
    
    @objc private func orderPersonalPhoneDidChange (_ sender: UITextField) {
        if let number = sender.text {
            for order in orderData {
                order.phone = number
            }
            if sender.text != "" {
                uploadUserOrder(prop: "Номер телефона", value: number)
            }
        }
    }
    
    @objc private func orderPersonalAddressDidChange (_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue))
        autocompleteController.placeFields = fields
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = Locale.current.regionCode
        autocompleteController.autocompleteFilter = filter
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension CheckOutViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if let comment = textView.text {
            for order in orderData {
                order.comment = comment
            }
            if textView.text != "" {
                uploadUserOrder(prop: "Комментарий к заказу", value: comment)
            }
        }
    }
}

extension CheckOutViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if let address = place.name {
            for order in orderData {
                order.deliveryAddress = String(describing: address)
            }
            if address != String(describing: "") {
                uploadUserOrder(prop: "Адрес доставки", value: String(describing: address))
            }
        }
        checkOutTable.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}
