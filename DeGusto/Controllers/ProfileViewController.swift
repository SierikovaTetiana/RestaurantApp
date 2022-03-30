//
//  ProfileViewController.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 26.08.2021.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FirebaseAuth

class ProfileViewController: UIViewController, LoginButtonDelegate {
    
    @IBOutlet weak var createNewAccountButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var socialView: UIView!
    @IBAction func forgotPassword(_ sender: UIButton) {
        forgotPasswordTapped()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    let err = e.localizedDescription
                    let alert = UIAlertController(title: "Что-то не так...", message: err, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "ProfileToAccount", sender: self)
                }
            }
        }
    }
    
    private lazy var url = documents.appendingPathComponent("ProfilePhoto.png")
    private let defaults = UserDefaults.standard
    private let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        view.backgroundColor = .white
        let loginButton = FBLoginButton()
        socialView.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: socialView.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: socialView.centerYAnchor).isActive = true
        loginButton.delegate = self
        loginButton.permissions = ["public_profile", "email"]
        createNewAccountButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    private func forgotPasswordTapped() {
        let alert = UIAlertController(title: "Сбросить пароль через email", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in textField.placeholder = "Адрес электронной почты"}
        alert.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { [weak alert] (_) in
            if let emailField = alert?.textFields?[0].text {
                Auth.auth().sendPasswordReset(withEmail: emailField) { error in
                    if let error = error {
                        let err = error.localizedDescription
                        let alert = UIAlertController(title: "Что-то пошло не так...", message: err, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        print("Error send Password reset \(error)")
                    } else {
                        let alert = UIAlertController(title: "Проверьте Вашу электронную почту", message: "", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Уже спешу🏃🏻‍♂️", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        print("Email successfully sended")
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Login with Facebook
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            guard let safeToken = AccessToken.current?.tokenString else {return}
            let credential = FacebookAuthProvider.credential(withAccessToken: safeToken)
            Auth.auth().signIn (with: credential) { (authResult, error) in
                if let error = error as NSError? {
                    print("Facebook authentication with Firebase error: ", error)
                    switch AuthErrorCode(rawValue: error._code) {
                    case .emailAlreadyInUse, AuthErrorCode(rawValue: 17012):
                        let alert = UIAlertController(title: "Войдите в аккаунт через это окошко", message: "Единоразово авторизуйтесь, чтоб иметь возможность входа через Facebook в дальнейшем", preferredStyle: UIAlertController.Style.alert)
                        alert.addTextField { (textField) in textField.placeholder = "Email"}
                        alert.addTextField { (textField) in textField.placeholder = "Пароль"}
                        alert.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { [weak alert] (_) in
                            if let alertTextFieldZero = alert?.textFields?[0], let alertTextFieldFirst = alert?.textFields?[1] {
                                if let email = alertTextFieldZero.text, let password = alertTextFieldFirst.text {
                                    let linkEmail = email
                                    let linkPassword = password
                                    Auth.auth().signIn(withEmail: linkEmail , password: linkPassword) {
                                        (authResult, error) in
                                        if let err = error {
                                            print("😢", err)
                                            let err = err.localizedDescription
                                            let alert = UIAlertController(title: "Что-то не так...", message: err, preferredStyle: UIAlertController.Style.alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                            self.present(alert, animated: true, completion: nil)
                                            
                                        } else {
                                            guard let accessToken = AccessToken.current?.tokenString else { return }
                                            let credential = FacebookAuthProvider
                                                .credential(withAccessToken: accessToken)
                                            authResult?.user.link(with: credential , completion: { (authResult, error) in
                                                if let error = error {
                                                    print("error", error)
                                                } else {
                                                    print("Success")
                                                }
                                            })
                                            self.performSegue(withIdentifier: "ProfileToAccount", sender: self)
                                        }
                                    }
                                }
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    default:
                        print("Other error", error._code)
                    }
                    return
                }
                print("Login success!")
                if authResult?.additionalUserInfo?.isNewUser == true {
                    self.fetchUserProfile()
                }
                self.performSegue(withIdentifier: "ProfileToAccount", sender: self)}
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("User tapped log out")
    }
    
    private func fetchUserProfile() {
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
        let _ = request.start (completion: { (connection, result, error) in
            guard let userInfo = result as? [String: Any] else { return }
            if let username = (userInfo["name"] as? String),
               let email = (userInfo["email"] as? String) {
                guard let userID = Auth.auth().currentUser?.uid else { return }
                Firestore.firestore().collection("users").document(userID).setData([
                    "email": email,
                    "data": Date().timeIntervalSince1970,
                    "username": username
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with UserID")
                    }
                }
            }
            if let imageURL = ((userInfo["picture"] as? [String: Any])? ["data"] as? [String: Any])?["url"] as? String {
                if let strintToURL = URL(string: imageURL) {
                    if let imageData = try? Data(contentsOf: strintToURL) {
                        do {
                            try imageData.write(to: self.url)
                            self.defaults.set(self.url, forKey: "ProfilePhoto")
                        } catch {
                            print("Unable to Write Data to Disk (\(error))")
                        }
                    }
                } else {
                    print("Error convert string to URL")
                }
            }
        })
    }
}
