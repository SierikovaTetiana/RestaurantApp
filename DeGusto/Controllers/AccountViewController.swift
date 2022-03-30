//
//  AccountViewController.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 11.09.2021.
//

import UIKit
import Firebase
import DatePickerDialog
import FBSDKLoginKit

class AccountViewController: UIViewController {
    
    @IBAction func cartButtonTapped(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "AccountToCart", sender: self)
        }
    }
    @IBOutlet weak var countData: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func siteButtonAction(_ sender: UIButton) {
        if let appURL = URL(string: "https://degustotrattoria.kh.ua") {
            UIApplication.shared.open(appURL, options: [:])
        }
    }
    
    @IBOutlet weak var siteButtonOutlet: UIButton!
    @IBAction func instagramButtonAction(_ sender: UIButton) {
        if let appURL = URL(string: "https://www.instagram.com/degusto.trattoria/") {
            UIApplication.shared.open(appURL, options: [:])
        }
    }
    @IBOutlet weak var instagramButtonOutlet: UIButton!
    @IBOutlet weak var facebookButtonOutlet: UIButton!
    @IBAction func facebookButtonAction(_ sender: UIButton) {
        if let appURL = URL(string: "https://www.facebook.com/trattoria.degusto/") {
            UIApplication.shared.open(appURL, options: [:])
        }
    }
    @IBOutlet weak var accountTableView: UITableView!
    @IBOutlet weak var accountPhoto: UIImageView!
    @IBAction func logOut(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        let manager = LoginManager()
        manager.logOut()
    }
    
    var sections : [SectionData] = [SectionData(open: true, data: [CellData(title: "Slider", image: nil, sectionImgName: "", cellData: [DishData(dishTitle: "", dishImage: nil, dishImgName: "", description: "", weight: 0, price: 0, favorite: false, cartCount: 0)])], order: -1)]
    var cartData = [CartData]()
    private let defaults = UserDefaults.standard
    private let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let imageData = ["person", "phone", "key", "envelope", "gift"]
    private let userData = ["username", "phoneNumber", "password", "email", "birthDate"]
    private let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
    private lazy var url = documents.appendingPathComponent("ProfilePhoto.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountTableView.delegate = self
        accountTableView.dataSource = self
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic(_:)))
        accountPhoto.addGestureRecognizer(gesture)
        navigationItem.hidesBackButton = true
        self.accountTableView.tableFooterView = UIView()
        setUserPhoto()
        getImageData()
    }
    
    private func setUserPhoto() {
        do {
            let data = try Data(contentsOf: url, options: [.mappedIfSafe, .uncached])
            accountPhoto.image = UIImage(data: data)
        } catch {
            accountPhoto.image = UIImage(named: "yourPhoto")
            print("Unable to Download User Photo from Disk (\(error))")
        }
    }
    
    private func getImageData() {
        let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let firstData = document.data() {
                    if let countTerm = firstData["data"] as? Double {
                        let unixtime = NSDate().timeIntervalSince1970
                        let difference = Int((unixtime - countTerm)/86400)
                        if difference <= 1 {
                            self.countData.text = "Вы с нами уже 1 день"
                        } else if difference < 5 {
                            self.countData.text = "Вы с нами уже \(difference) дня"
                        } else {
                            self.countData.text = "Вы с нами уже \(difference) дней"
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}


// MARK: - Account photo

extension AccountViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc private func didTapChangeProfilePic(_ gesture:UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: "Здесь можно загрузить в профиль фото себя любимого:)", message: "Как Вы хотите это сделать?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Сделать фото сейчас", style: .default, handler: {[weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Выбрать фото из галереи", style: .default, handler: {[weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    
    private func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    private func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        guard let imageData = selectedImage.pngData() else {return}
        do {
            try imageData.write(to: url)
            defaults.set(url, forKey: "ProfilePhoto")
        } catch {
            print("Unable to Write Data to Disk (\(error))")
        }
        do {
            let data = try Data(contentsOf: url, options: [.mappedIfSafe, .uncached])
            self.accountPhoto.image = UIImage(data: data)
        } catch {
            print("Unable to Download User Photo from Disk (\(error))")
        }
    }
}

// MARK: - Table View Section

extension AccountViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userInfo", for: indexPath) as? AccountTableViewCell else { return UITableViewCell() }
        cell.updateButtonOutlet.tag = indexPath.row
        cell.sysImageInTable.image = UIImage(systemName: self.imageData[indexPath.row])
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let firstData = document.data() {
                    if indexPath.row == 0 {
                        if let username = firstData["username"] {
                            cell.labelInTable.text = "\(username)"
                        } else {
                            cell.labelInTable.text = "Ваше имя"
                            cell.labelInTable.textColor = UIColor.darkGray
                        }
                    }
                    if indexPath.row == 1 {
                        if let phoneNumber = firstData["phoneNumber"] {
                            cell.labelInTable.text = "\(phoneNumber)"
                        } else {
                            cell.labelInTable.text = "Ваш номер телефона"
                            cell.labelInTable.textColor = UIColor.darkGray
                        }
                    }
                    if indexPath.row == 2 {
                        cell.labelInTable.text = "******"
                    }
                    if indexPath.row == 3 {
                        if let email = firstData["email"] {
                            cell.labelInTable.text = "\(email)"
                        }
                    }
                    if indexPath.row == 4 {
                        if let birthDate = firstData["birthDate"] {
                            cell.labelInTable.text = "\(birthDate)"
                            cell.updateButtonOutlet.isEnabled = false
                            cell.updateButtonOutlet.setImage(UIImage(systemName: "lock"), for: .normal)
                        } else {
                            cell.labelInTable.text = "Ваш День Рождения"
                            cell.labelInTable.textColor = UIColor.darkGray
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
        cell.updateButtonOutlet.addTarget(self, action: #selector(updateButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    // MARK: - Update data in Table
    
    @objc private func updateButtonTapped(_ sender: UIButton) {
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let firstData = document.data() {
                    switch sender.tag {
                    case 0:
                        let alert = UIAlertController(title: "Изменить имя", message: "", preferredStyle: .alert)
                        alert.addTextField { (textField) in textField.placeholder = "\(firstData["\(self.userData[sender.tag])"] ?? "Ваше имя")"}
                        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak alert] (_) in
                            if let textField = alert?.textFields?[0] {
                                guard let textFieldText = textField.text else { return }
                                self.accountTableView.reloadData()
                                self.docRef.updateData(([
                                    "\(self.userData[sender.tag])": textFieldText as Any]), completion: { err in
                                        if let err = err {
                                            print("Error updating document: \(err)")
                                        } else {
                                            print("Document successfully updated")
                                        }})
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        //        change phone number
                    case 1:
                        let alert = UIAlertController(title: "Изменить номер телефона", message: "", preferredStyle: .alert)
                        alert.addTextField { (textField) in textField.placeholder = "\(firstData["\(self.userData[sender.tag])"] ?? "+380501234567")"}
                        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak alert] (_) in if let textField = alert?.textFields?[0] {
                            guard let textFieldText = textField.text else { return }
                            self.accountTableView.reloadData()
                            self.docRef.updateData(([
                                "\(self.userData[sender.tag])": textFieldText as Any]), completion: { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                    }})
                        }
                        }))
                        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        //            change password
                    case 2:
                        let user = Auth.auth().currentUser
                        let alert = UIAlertController(title: "Новый пароль", message: "", preferredStyle: .alert)
                        alert.addTextField { (textField) in textField.placeholder = "Старый пароль"
                            textField.isSecureTextEntry = true}
                        alert.addTextField { (textField) in textField.placeholder = "Новый пароль"; textField.isSecureTextEntry = true}
                        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: {[weak alert] (_) in
                            guard let oldPassword = alert?.textFields?[0].text else { return }
                            guard let newPassword = alert?.textFields?[1].text else { return }
                            guard let firstDataEmail = firstData["email"] as? String else { return }
                            let credential = EmailAuthProvider.credential(withEmail: firstDataEmail, password: oldPassword)
                            user?.reauthenticate(with: credential, completion: { (result, error) in
                                if let err = error {
                                    print("Error re-auth password: \(err)")
                                } else {
                                    Auth.auth().currentUser?.updatePassword(to: newPassword) { err in
                                        if let err = err {
                                            let err = err.localizedDescription
                                            let alert = UIAlertController(title: "Не получилось обновить пароль. Попробуйте еще раз", message: err, preferredStyle: UIAlertController.Style.alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                            self.present(alert, animated: true, completion: nil)
                                            print("Error updating password: \(err)")
                                        } else {
                                            print("Password successfully updated")
                                        }}
                                }
                            })
                        }))
                        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        //            change email:
                    case 3:
                        let user = Auth.auth().currentUser
                        let alert = UIAlertController(title: "Изменить email", message: "", preferredStyle: .alert)
                        
                        alert.addTextField { (textField) in textField.placeholder = "\(firstData[self.userData[sender.tag]] ?? "your_email@gmail.com")"}
                        alert.addTextField { (textField) in textField.placeholder = "Пароль аккаунта"
                            textField.isSecureTextEntry = true}
                        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak alert] (_) in guard let newEmail = alert?.textFields?[0].text else { return }
                            guard let password = alert?.textFields?[1].text  else { return }
                            guard let firstDataEmail = firstData["email"] as? String else { return }
                            let credential = EmailAuthProvider.credential(withEmail: firstDataEmail, password: password)
                            user?.reauthenticate(with: credential, completion: { (result, error) in
                                if let err = error {
                                    print("Error re-auth email: \(err)")
                                } else {
                                    Auth.auth().currentUser?.updateEmail(to: newEmail) { err in
                                        if let err = err {
                                            let err = err.localizedDescription
                                            let alert = UIAlertController(title: "Не получилось обновить email. Попробуйте еще раз", message: err, preferredStyle: UIAlertController.Style.alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                            self.present(alert, animated: true, completion: nil)
                                            print("Error updating email: \(err)")
                                        } else {
                                            self.docRef.updateData((["\(self.userData[sender.tag])": newEmail]), completion: { err in
                                                if let err = err {
                                                    print("Error updating document: \(err)")
                                                } else {
                                                    print("Document successfully updated")
                                                }})
                                            self.accountTableView.reloadData()
                                            print("Email successfully updated")
                                        }}
                                }
                            })
                        }))
                        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        //case 4. Birth date
                    case 4:
                        DatePickerDialog().show("DatePicker", doneButtonTitle: "Сохранить", cancelButtonTitle: "Отменить", datePickerMode: .date) { date in
                            if let dt = date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MM/dd/yyyy"
                                print(formatter.string(from: dt))
                                self.docRef.updateData((["\(self.userData[sender.tag])": formatter.string(from: dt)]), completion: { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                    }})
                                self.accountTableView.reloadData()
                                print("Birth date successfully updated")
                            }
                        }
                    default:
                        print("Something unexpected was tapped")
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AccountToCart" {
            guard let vc = segue.destination as? CartViewController else { return }
            vc.sections = sections
            vc.cartData = cartData
        }
    }
}
