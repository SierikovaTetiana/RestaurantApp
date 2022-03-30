//
//  CreateAccountViewController.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 12.09.2021.
//

import UIKit
import Firebase
import PhoneNumberKit

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var privacyPolicyOutlet: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneNumber: PhoneNumberTextField!
    @IBAction func privacyPolicyButton(_ sender: UIButton) {
        print("Privacy polisy tapped!")
    }
    
    @IBAction func registrationPressed(_ sender: UIButton) {
        if let email = emailField.text, let password = passwordField.text, let phone = phoneNumber.text {
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNum = try phoneNumberKit.parse(phone)
                let num = phoneNumberKit.format(phoneNum, toType: .e164)
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                Auth.auth().currentUser?.link (with: credential) { authResult, error in
                    if let e = error {
                        print(e.localizedDescription)
                        let err = e.localizedDescription
                        let alert = UIAlertController(title: "Что-то не так...", message: err, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        guard let userID = authResult?.user.uid else {return}
                        Firestore.firestore().collection("users").document(userID).setData([
                            "email": email,
                            "phoneNumber": num,
                            "data": Date().timeIntervalSince1970
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("Document added with UserID")
                            }
                        }
                        self.performSegue(withIdentifier: "CreateAccountToAccount", sender: self)
                    }
                }
            }
            catch {
                let err = error.localizedDescription
                let alert = UIAlertController(title: "Что-то не так...", message: err, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("Generic parser error")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        phoneNumber.withExamplePlaceholder = true
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
}
