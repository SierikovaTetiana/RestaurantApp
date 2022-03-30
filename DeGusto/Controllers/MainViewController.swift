//
//  MainViewController.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 25.08.2021.
//

import UIKit
import Firebase
import Reachability
import FaveButton
import PKYStepper

class MainViewController: UIViewController {
    
    @IBAction func cartButtonNavBarTapped(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "MainToCart", sender: self)
        }
    }
    
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        if Auth.auth().currentUser == nil || Auth.auth().currentUser!.isAnonymous {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "MainToProfile", sender: self)
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "MainToAccount", sender: self)
            }
        }
    }
    
    @IBOutlet weak var table: UITableView!
    
    var cartData = [CartData]()
    var sections : [SectionData] = [SectionData(open: true, data: [CellData(title: "Slider", image: nil, sectionImgName: "", cellData: [DishData(dishTitle: "", dishImage: nil, dishImgName: "", description: "", weight: 0, price: 0, favorite: false, cartCount: 0)])], order: -1)]
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var userUid = String()
    private var toCartButton = UIButton()
    private var favorite = [String]()
    private var cartDishCount = [String: Int]()
    private var cartDishWithPrice = [String: Int]()
    private var dishData = [CellData]()
    private var faveData = [CellData]()
    private var favDishData = [DishData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "dishTableViewCell", bundle: nil), forCellReuseIdentifier: "dishCell")
        Database.database().reference().keepSynced(true)
        authorizeUser()
        goToCart()
        addActionToGoToCartButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        netTester()
        getUserFavorites()
    }

    // MARK: - Get text Data from DB
    
    private func getDataMenu() {
        sections = [SectionData(open: true, data: [CellData(title: "Slider", image: nil, sectionImgName: "", cellData: [DishData(dishTitle: "", dishImage: nil, dishImgName: "", description: "", weight: 0, price: 0, favorite: false, cartCount: 0)])], order: -1)]
        var order = 0
        Database.database().reference().child("menu").observe(.value, with: { snapshot in
            if !snapshot.exists() { return }
            if let menuDict : Dictionary = snapshot.value as? Dictionary<String,Any> {
                for (key, value) in menuDict {
                    let sectionDishTitle = value
                    let sectionDishTitleKey = key
                    if let dishDict : Dictionary = sectionDishTitle as? Dictionary<String,Any> {
                        for (key, value) in dishDict {
                            let descrDish = value
                            let descrDishKey = key
                            if let ord = dishDict["order"] as? Int {
                                order = ord
                            }
                            let sectionImgName = dishDict["sectionImgName"]
                            if let descrDishDict : Dictionary = descrDish as? Dictionary<String,Any> {
                                var weight = descrDishDict["weight"] as? Int
                                var description = descrDishDict["description"]
                                var price = descrDishDict["price"] as? Int
                                var dishImageName = descrDishDict["dishImageName"]
                                for (_, _) in descrDishDict {
                                    weight = descrDishDict["weight"] as? Int
                                    price = descrDishDict["price"] as? Int
                                    description = descrDishDict["description"]
                                    dishImageName = descrDishDict["dishImageName"]
                                }
                                let img = UIImage()
                                if let safeDishImageName = dishImageName, let safeDescription = description, let safeSectionImageName = sectionImgName {
                                    
                                    if !self.favorite.isEmpty {
                                        if !self.favorite.contains(where: {$0 == descrDishKey}) {
                                            self.dishData.append(contentsOf: [CellData(title: "\(sectionDishTitleKey)", image: UIImage(named: "pizza")!, sectionImgName: "\(String(describing: safeSectionImageName))", cellData: [DishData(dishTitle: "\(descrDishKey)", dishImage: img, dishImgName: "\(String(describing: safeDishImageName))", description: "\(String(describing: safeDescription))", weight: weight ?? 0, price: price ?? 0, favorite: false, cartCount: 0)])])
                                            
                                        } else {
                                            for faveDish in self.favorite {
                                                if faveDish == descrDishKey {
                                                    self.faveData.append(contentsOf: [CellData(title: "\(sectionDishTitleKey)", image: UIImage(systemName: "heart")!, sectionImgName: "", cellData: [DishData(dishTitle: "\(descrDishKey)", dishImage: img, dishImgName: "\(String(describing: safeDishImageName))", description: "\(String(describing: safeDescription))", weight: weight ?? 0, price: price ?? 0, favorite: true, cartCount: 0)])])
                                                    
                                                    self.dishData.append(contentsOf: [CellData(title: "\(sectionDishTitleKey)", image: UIImage(named: "pizza")!, sectionImgName: "\(String(describing: safeSectionImageName))", cellData: [DishData(dishTitle: "\(descrDishKey)", dishImage: img, dishImgName: "\(String(describing: safeDishImageName))", description: "\(String(describing: safeDescription))", weight: weight ?? 0, price: price ?? 0, favorite: true, cartCount: 0)])])
                                                }
                                            }
                                        }
                                        
                                    } else {
                                        self.dishData.append(contentsOf: [CellData(title: "\(sectionDishTitleKey)", image: UIImage(named: "pizza")!, sectionImgName: "\(String(describing: safeSectionImageName))", cellData: [DishData(dishTitle: "\(descrDishKey)", dishImage: img, dishImgName: "\(String(describing: safeDishImageName))", description: "\(String(describing: safeDescription))", weight: weight ?? 0, price: price ?? 0, favorite: false, cartCount: 0)])])
                                    }
                                }
                            }
                        }
                    }
                    self.sections.append(SectionData(open: false, data: self.dishData, order: order))
                    self.dishData = [CellData]()
                    self.sections = self.sections.sorted(by: { $0.order < $1.order })
                }
                if !self.faveData.isEmpty {
                    self.sections.append(SectionData(open: false, data: self.faveData, order: 0))
                    self.faveData = [CellData]()
                }
                self.sections = self.sections.sorted(by: { $0.order < $1.order })
                self.table.reloadData()
            }
            self.getSectionImages()
        })
    }
    
    // MARK: - Get Images for sections and dishes from DB
    
    private func getSectionImages() {
        for item in sections {
            let storageRef = storage.reference().child("sectionImages").child("\(item.data[0].sectionImgName).jpg")
            storageRef.getData(maxSize: 1 * 480 * 480) { data, error in
                if let error = error {
                    if item.data[0].sectionImgName != "" && item.data[0].sectionImgName != "example" {
                        print("Uh-oh, an error occurred getSectionImages!", error)
                    }
                } else {
                    if let imgData = data {
                        if let image = UIImage(data: imgData) {
                            item.data[0].sectionImage = image
                        }
                    }
                    self.table.reloadData()
                }
            }
        }
    }
    
    private func getImagesForMenu (handler: @escaping (_ image : UIImage?) -> Void, currentSectionTitle : String, currentSection: Int) {
        if sections[currentSection].open {
            for sec in sections {
                sec.open = false
                sections[0].open = true
                sections[currentSection].open = true
            }
        }
        if currentSection == 1 {
            for cellData in self.sections[currentSection].data {
                for dishData in cellData.cellData {
                    let storageRef = storage.reference().child("menuImages").child("\(cellData.title)/\(dishData.dishImgName).jpg")
                    storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            handler(nil)
                            if dishData.dishImgName != "" && dishData.dishImgName != "example" {
                                print("Uh-oh, an error occurred getImagesForMenu currentSection == 1!", error)
                            }
                        } else {
                            if let imgData = data {
                                if let image = UIImage(data: imgData) {
                                    dishData.dishImage = image
                                    handler(image)
                                }
                            }
                            if self.table.indexPathExists(indexPath: IndexPath(row: 0, section: currentSection)) {
                                self.table.scrollToRow(at: IndexPath(row: 0, section: currentSection), at: .top, animated: true)
                            }
                            self.table.reloadData()
                        }
                    }
                }
            }
        } else {
            for cellData in self.sections[currentSection].data {
                for dishData in cellData.cellData {
                    let storageRef = storage.reference().child("menuImages").child("\(currentSectionTitle)/\(dishData.dishImgName).jpg")
                    storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            handler(nil)
                            if dishData.dishImgName != "" && dishData.dishImgName != "example" {
                                print("Uh-oh, an error occurred getImagesForMenu!", error)
                            }
                        } else {
                            if let imgData = data {
                                if let image = UIImage(data: imgData) {
                                    dishData.dishImage = image
                                    handler(image)
                                }
                            }
                            if self.table.indexPathExists(indexPath: IndexPath(row: 0, section: currentSection)) {
                                self.table.scrollToRow(at: IndexPath(row: 0, section: currentSection), at: .top, animated: true)
                            }
                            self.table.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Manage User Favorite (Get data from DB, faveButtonAction)
    
    private func getUserFavorites() {
        favorite = [String]()
        if Auth.auth().currentUser != nil {
            let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let firstData = document.data() {
                        if let favorites = firstData["favorites"] as? Array<String> {
                            for item in favorites {
                                self.favorite.append(item)
                                for section in self.sections {
                                    for data in section.data {
                                        for dish in data.cellData {
                                            for fav in self.favorite {
                                                if fav == dish.dishTitle {
                                                    dish.favorite = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if self.sections.count < 2 {
                    self.getDataMenu()
                }
                self.getUserCart()
            }
        }
    }
    
    @objc private func faveButtonAction(sender: UIButton!) {
        let docRef = Firestore.firestore().collection("users").document(userUid)
        guard let senderAccessLabel = sender.accessibilityLabel else { return }
        docRef.getDocument { (document, error) in
            if sender.isSelected == false {
                docRef.updateData((["favorites": FieldValue.arrayRemove([senderAccessLabel])]), completion: { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        self.favorite.removeAll(where: { $0 == sender.accessibilityLabel })
                        for section in self.sections {
                            for data in section.data {
                                for dish in data.cellData {
                                    if sender.accessibilityLabel == dish.dishTitle {
                                        dish.favorite = false
                                        if self.favorite.isEmpty {
                                            self.sections.removeAll(where: { $0.order == 0 })
                                        } else {
                                            self.sections[1].data.removeAll(where: { $0.cellData[0].dishTitle ==  sender.accessibilityLabel })
                                        }
                                    }
                                }
                            }
                        }
                        self.table.reloadData()
                        print("Document successfully updated. Dish was deleted from favorite section")
                    }})
            } else {
                docRef.updateData((["favorites": FieldValue.arrayUnion([senderAccessLabel])]), completion: { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        if !self.favorite.contains(where: {$0 == senderAccessLabel}) {
                            self.favorite.append(senderAccessLabel)
                            for section in self.sections {
                                for data in section.data {
                                    for dish in data.cellData {
                                        if sender.accessibilityLabel == dish.dishTitle {
                                            guard let dishImage = dish.dishImage else { return }
                                            if self.sections[1].order == 0 {
                                                self.sections[1].data.append(CellData(title: data.title, image: UIImage(systemName: "heart")!, sectionImgName: data.sectionImgName, cellData: [DishData(dishTitle: dish.dishTitle, dishImage: dishImage, dishImgName: dish.dishImgName, description: dish.description, weight: dish.weight, price: dish.price, favorite: true, cartCount: 0)]))
                                            } else {
                                                self.sections.append(SectionData(open: false, data: [CellData(title: data.title, image: UIImage(systemName: "heart")!, sectionImgName: data.sectionImgName, cellData: [DishData(dishTitle: dish.dishTitle, dishImage: dishImage, dishImgName: dish.dishImgName, description: dish.description, weight: dish.weight, price: dish.price, favorite: true, cartCount: 0)])], order: 0))
                                                self.sections = self.sections.sorted(by: { $0.order < $1.order })
                                            }
                                            dish.favorite = true
                                        }
                                    }
                                }
                            }
                        }
                        self.table.reloadData()
                        print("Document successfully updated. Dish was added to sections")
                    }})
            }
        }
    }
    
    // MARK: - AuthorizeUser/signInAnonymously -> get userUID needed to add user favorites to DB
    
    private func authorizeUser() {
        if Auth.auth().currentUser != nil {
            userUid = Auth.auth().currentUser!.uid
        } else {
            Auth.auth().signInAnonymously { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    let err = e.localizedDescription
                    let alert = UIAlertController(title: "Что-то не так...", message: err, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    guard let user = authResult?.user else { return }
                    self.userUid = user.uid
                    self.db.collection("users").document(self.userUid).setData([ "favorites": [] ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with UserID")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Manage user Cart
    
    private func getUserCart() {
        if Auth.auth().currentUser != nil {
            let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let firstData = document.data() {
                        self.cartData.removeAll()
                        self.cartDishCount.removeAll()
                        self.cartDishWithPrice.removeAll()
                        if let cartData = firstData["cart"] as? Dictionary<String, Any> {
                            for item in cartData {
                                self.cartDishCount[item.key] = item.value as? Int
                                var price = 0
                                for section in self.sections {
                                    for data in section.data {
                                        for dish in data.cellData {
                                            if item.key == dish.dishTitle {
                                                if let dishCartCount = item.value as? Int {
                                                    dish.cartCount = dishCartCount
                                                    price = dish.price * dish.cartCount
                                                    self.cartDishWithPrice[item.key] = dish.price * dish.cartCount
                                                }
                                            }
                                        }
                                    }
                                }
                                if let itemValueCartData = item.value as? Int {
                                    self.cartData.append(contentsOf: [CartData(dishTitle: item.key, count: itemValueCartData, price: price)])
                                }
                            }
                        }
                    }
                }
                self.table.reloadData()
                self.goToCart()
            }
        }
    }
    
    private func stepperAction(sender: PKYStepper!, dish: String, addDish: UIButton) {
        sender.valueChangedCallback = { (stepper, count) -> Void in
            sender.countLabel.text = "\(Int(count))"
            if let userUid = Auth.auth().currentUser?.uid {
                let docRef = Firestore.firestore().collection("users").document(userUid)
                if count == 0 {
                    sender.removeFromSuperview()
                    addDish.isHidden = false
                    docRef.updateData([
                        "cart.\(dish)": FieldValue.delete(),
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            for section in self.sections {
                                for data in section.data {
                                    for meal in data.cellData {
                                        if meal.dishTitle == dish {
                                            meal.cartCount = 0
                                        }
                                    }
                                }
                            }
                            if let index = self.cartData.firstIndex(where: { $0.dishTitle == dish}) {
                                self.cartData.remove(at: index)
                            }
                            self.cartDishWithPrice.removeValue(forKey: dish)
                            self.cartDishCount.removeValue(forKey: dish)
                            if self.cartDishCount.count == 0 {
                                self.toCartButton.isHidden = true
                                self.table.contentInset.bottom = 0
                            }
                            self.toCartButton.setTitle("В корзине \(self.cartDishCount.values.reduce(0, +)) \(self.dishNameInLabel()) на \(self.cartDishWithPrice.values.reduce(0, +)) грн.", for: .normal)
                        }
                    }
                } else {
                    docRef.updateData(["cart.\(dish)": count]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            var price = 0
                            for section in self.sections {
                                for data in section.data {
                                    for meal in data.cellData {
                                        if meal.dishTitle == dish {
                                            meal.cartCount = Int(count)
                                            price = meal.price * meal.cartCount
                                            self.cartDishWithPrice[dish] = meal.price * meal.cartCount
                                        }
                                    }
                                }
                            }
                            if self.cartData.isEmpty {
                                self.cartData.append(contentsOf: [CartData(dishTitle: dish, count: Int(count), price: price)])
                            }
                            for x in self.cartData {
                                if !self.cartData.contains(where: {$0.dishTitle == dish}) {
                                    self.cartData.append(contentsOf: [CartData(dishTitle: dish, count: Int(count), price: price)])
                                } else {
                                    if x.dishTitle == dish {
                                        x.count = Int(count)
                                        x.price = price
                                    }
                                }
                            }
                            self.table.contentInset.bottom = 50
                            self.toCartButton.isHidden = false
                            self.cartDishCount[dish] = Int(count)
                            self.toCartButton.setTitle("В корзине \(self.cartDishCount.values.reduce(0, +)) \(self.dishNameInLabel()) на \(self.cartDishWithPrice.values.reduce(0, +)) грн.", for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - GotoCart Button(appears when user tap add to cart)
    
    private func goToCart() {
        if self.cartData.count == 0 {
            toCartButton.isHidden = true
            self.table.contentInset.bottom = 0
        } else {
            toCartButton.isHidden = false
            self.table.contentInset.bottom = 50
        }
        toCartButton.setTitle("В корзине \(self.cartDishCount.values.reduce(0, +)) \(dishNameInLabel()) на \(self.cartDishWithPrice.values.reduce(0, +)) грн.", for: .normal)
        toCartButton.backgroundColor = UIColor(named: "darkRed")
        toCartButton.translatesAutoresizingMaskIntoConstraints = false
        toCartButton.alpha = 0.8
        view.addSubview(toCartButton)
        NSLayoutConstraint.activate([
            toCartButton.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor),
            toCartButton.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor),
            toCartButton.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor,constant: -50),
            toCartButton.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func dishNameInLabel() -> String {
        if self.cartDishCount.values.reduce(0, +) >= 5 && self.cartDishCount.values.reduce(0, +) < 99 {
            return "товаров"
        } else if self.cartDishCount.values.reduce(0, +) == 1 || self.cartDishCount.values.reduce(0, +) == 101 {
            return "товар"
        } else {
            return "товара"
        }
    }
    
    private func addActionToGoToCartButton() {
        toCartButton.addAction(UIAction(handler: {_ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "MainToCart", sender: self)
            }
        }), for: .touchUpInside)
    }
    
    // MARK: - PrepareToSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToCart" {
            guard let vc = segue.destination as? CartViewController else { return }
            vc.sections = sections
            vc.cartData = cartData
        } else if segue.identifier == "MainToAccount" {
            guard let vc = segue.destination as? AccountViewController else { return }
            vc.sections = sections
            vc.cartData = cartData
        }
    }
    
    // MARK: - Internet connection checker

    private func netTester() {
        guard let reachability = try? Reachability() else { return }
        if ((reachability.connection) != .unavailable) {
            print("Internet is Ok")
        } else{
            print("Internet is nO ok")
            let controller = UIAlertController(title: "Внимание", message: "Пожалуйста, проверьте доступ в интернет и попробуйте снова", preferredStyle: .alert)
            let ok = UIAlertAction(title: "ХОРОШО", style: .default, handler: nil)
            controller.addAction(ok)
            present(controller, animated: true, completion: nil)
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    //    Sections:
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let title = UILabel()
            title.textAlignment = .center
            return title
        } else {
            let button = UIButton(type: .custom)
            let image = UIImageView(image: sections[section].data[0].sectionImage)
            image.frame.size = CGSize(width: 50, height: 50)
            image.layer.cornerRadius = 25
            image.layer.masksToBounds = true
            image.frame = image.frame.offsetBy(dx: 10, dy: 10)
            button.addSubview(image)
            if section == 1 && !self.favorite.isEmpty {
                button.setTitle("Улюблене", for: .normal)
            } else {
                button.setTitle(sections[section].data[0].title, for: .normal)
            }
            if sections[section].open == false {
                button.setImage(UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .heavy)), for: .normal)
            } else {
                button.setImage(UIImage(systemName: "arrow.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .heavy)), for: .normal)
            }
            button.semanticContentAttribute = .forceRightToLeft
            button.contentHorizontalAlignment = .right
            button.imageView?.translatesAutoresizingMaskIntoConstraints = false
            button.imageView?.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: 0.0).isActive = true
            button.imageView?.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 30.0).isActive = true
            button.contentHorizontalAlignment = .left
            button.backgroundColor = .white
            button.contentEdgeInsets.left = 80
            button.setTitleColor(.black, for: .normal)
            button.tag = section
            button.addTarget(self, action: #selector(self.hideSection(sender:)), for: .touchUpInside)
            return button
        }
    }
    
    @objc private func hideSection(sender: UIButton) {
        let section = sender.tag
        sections[section].open = !sections[section].open
        var indexPaths = [IndexPath]()
        for row in sections[section].data.indices {
            let indexPathToDelete = IndexPath(row: row, section: section)
            indexPaths.append(indexPathToDelete)
        }
        
        if sections[section].open {
            sender.setImage(UIImage(systemName: "arrow.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .heavy)), for: .normal)
            sender.backgroundColor = UIColor(red: 39/255, green: 78/255, blue: 19/255, alpha: 0.2)
            table.insertRows(at: indexPaths, with: .fade)
            self.getImagesForMenu (handler: { (image) -> Void in }, currentSectionTitle: sections[section].data[0].title, currentSection: section)
        } else {
            sender.setImage(UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .heavy)), for: .normal)
            sender.backgroundColor = .white
            table.deleteRows(at: indexPaths, with: .fade)
        }
    }
    
    //    Rows:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !sections[section].open {
            return 0
        } else {
            return sections[section].data.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 250
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "scrollCell", for: indexPath) as? CategoryRow
                else { return UITableViewCell() }
            if cell.scroll_timer != nil {
                if let scrollTimer = cell.scroll_timer {
                    scrollTimer.invalidate()
                    cell.scroll_timer = nil
                }
            }
            cell.setTimer()
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "dishCell", for: indexPath) as? dishTableViewCell else { return UITableViewCell() }
            cell.dishImage.image = sections[indexPath.section].data[indexPath.row].cellData[0].dishImage
            cell.titleDish.text = sections[indexPath.section].data[indexPath.row].cellData[0].dishTitle
            cell.descriptionDish.text = sections[indexPath.section].data[indexPath.row].cellData[0].description
            cell.weightDish.text = "\(sections[indexPath.section].data[indexPath.row].cellData[0].weight) г."
            cell.priceDish.text = "\(sections[indexPath.section].data[indexPath.row].cellData[0].price) ₴"
            
            cell.faveButton.delegate = self
            cell.faveButton.backgroundColor = .white
            cell.faveButton.layer.cornerRadius = 22
            cell.faveButton.tag = indexPath.row
            cell.faveButton.accessibilityLabel = "\(sections[indexPath.section].data[indexPath.row].cellData[0].dishTitle)"
            cell.addSubview(cell.faveButton)
            cell.faveButton.addTarget(self, action: #selector(faveButtonAction), for: .touchUpInside)
            if sections[indexPath.section].data[indexPath.row].cellData[0].favorite == true {
                cell.faveButton.setSelected(selected: true, animated: false)
            } else {
                cell.faveButton.setSelected(selected: false, animated: false)
            }
            
            cell.stepper.backgroundColor = .white
            cell.stepper.setLabelTextColor(.black)
            cell.stepper.setBorderColor(.white)
            cell.stackViewAddDish.addSubview(cell.stepper)
            if let cellTitleDish = cell.titleDish.text {
                stepperAction(sender: cell.stepper, dish: cellTitleDish, addDish: cell.addDish)
            }
            
            if sections[indexPath.section].data[indexPath.row].cellData[0].cartCount > 0 {
                cell.addDish.isHidden = true
                cell.stepper.value = Float(sections[indexPath.section].data[indexPath.row].cellData[0].cartCount)
                cell.stepper.countLabel.text = String(sections[indexPath.section].data[indexPath.row].cellData[0].cartCount)
                cell.stepper.setButtonTextColor(UIColor(named: "darkRed"), for: .normal)
            } else if sections[indexPath.section].data[indexPath.row].cellData[0].cartCount == 0 {
                cell.stepper.countLabel.text = "0"
                cell.stepper.setButtonTextColor(UIColor(named: "white"), for: .normal)
                cell.stepper.removeFromSuperview()
                cell.addDish.isHidden = false
                cell.backgroundColor = .white
            }
            
            cell.addDish.addAction(UIAction(handler: {_ in
                cell.addDish.isHidden = true
                cell.stackViewAddDish.addSubview(cell.stepper)
                cell.stepper.value = 1
                cell.stepper.countLabel.text = "1"
                cell.stepper.setButtonTextColor(UIColor(named: "darkRed"), for: .normal)
            }), for: .touchUpInside)
            
            return cell
        }
    }
}

extension UITableView {
    func indexPathExists(indexPath:IndexPath) -> Bool {
        if indexPath.section >= self.numberOfSections {
            return false
        }
        if indexPath.row >= self.numberOfRows(inSection: indexPath.section) {
            return false
        }
        return true
    }
}
