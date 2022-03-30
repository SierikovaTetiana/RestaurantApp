//
//  CartViewController.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 04.10.2021.
//

import Foundation
import Firebase
import PKYStepper
import SDStateTableView

class CartViewController: UIViewController {
    
    @IBAction func deleteAll(_ sender: UIButton) {
        cartData.removeAll()
        cartIsEmpty()
    }
    
    @IBOutlet weak var deleteAllOutlet: UIButton!
    @IBOutlet weak var cartTable: SDStateTableView!
    @IBOutlet weak var totalSum: UILabel!
    @IBOutlet weak var cartStackView: UIStackView!
    
    private var orderButton = UIButton()
    private var totalSumCount = [String: Int]()
    var sections: [SectionData] = [SectionData(open: true, data: [CellData(title: "Slider", image: nil, sectionImgName: "", cellData: [DishData(dishTitle: "", dishImage: nil, dishImgName: "", description: "", weight: 0, price: 0, favorite: false, cartCount: 0)])], order: -1)]
    var cartData = [CartData]().sorted(by: { $0.dishTitle < $1.dishTitle })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cartTable.delegate = self
        cartTable.dataSource = self
        cartTable.register(UINib(nibName: "cartTableViewCell", bundle: nil), forCellReuseIdentifier: "cartCell")
        Database.database().reference().keepSynced(true)
        countTotalSum()
        if !self.cartData.contains(where: {$0.dishTitle == "Количество приборов"}) {
            cartData.append(contentsOf: [CartData(dishTitle: "Количество приборов", count: 0, price: 0)])}
        goToOrderButton()
        if self.cartData.count == 1 {
            for item in self.cartData {
                if item.dishTitle == "Количество приборов" {
                    self.cartIsEmpty()
                }
            }
        }
    }
    
    private func countTotalSum() {
        for item in cartData {
            totalSumCount[item.dishTitle] = item.price
        }
        totalSum.text = "\(totalSumCount.values.reduce(0, +)) ₴"
    }
    
    private func dishStepperAction(sender: PKYStepper, dish: String, dishPrice: UILabel) {
        sender.valueChangedCallback = { (stepper, count) -> Void in
            sender.countLabel.text = "\(Int(count))"
            if let userUid = Auth.auth().currentUser?.uid {
                let docRef = Firestore.firestore().collection("users").document(userUid)
                if count == 0 {
                    sender.removeFromSuperview()
                    docRef.updateData([
                        "cart.\(dish)": FieldValue.delete(),
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.totalSumCount.removeValue(forKey: dish)
                            self.totalSum.text = "\(self.totalSumCount.values.reduce(0, +)) ₴"
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
                                let indexPath = IndexPath(item: index, section: 0)
                                self.cartTable.deleteRows(at: [indexPath], with: .fade)
                            }
                            if self.cartData.count == 1 {
                                for item in self.cartData {
                                    if item.dishTitle == "Количество приборов" {
                                        self.cartIsEmpty()
                                    }
                                }
                            }
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
                                        }
                                    }
                                }
                            }
                            self.totalSumCount[dish] = Int(price)
                            for x in self.cartData {
                                if !self.cartData.contains(where: {$0.dishTitle == dish}) {
                                    self.cartData.append(contentsOf: [CartData(dishTitle: dish, count: Int(count), price: price)])
                                }
                                else {
                                    if x.dishTitle == dish {
                                        x.count = Int(count)
                                        x.price = price
                                        dishPrice.text = "\(x.price) ₴"
                                    }
                                }
                                self.totalSum.text = "\(self.totalSumCount.values.reduce(0, +)) ₴"
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func loadImages (handler: @escaping (_ image : UIImage?) -> Void, dish: String) {
        for section in self.sections {
            for data in section.data {
                for meal in data.cellData {
                    if meal.dishTitle == dish {
                        guard let mealImage = meal.dishImage else { return }
                        if mealImage.size.width != 0 {
                            handler(meal.dishImage)
                        } else {
                            let storageRef = Storage.storage().reference().child("menuImages").child("\(data.title)/\(meal.dishImgName).jpg")
                            storageRef.getData(maxSize: 1 * 480 * 480) { data, error in
                                if let error = error {
                                    handler(nil)
                                    print("Uh-oh, an error occurred!", error)
                                } else {
                                    if let imgData = data {
                                        if let image = UIImage(data: imgData) {
                                            meal.dishImage = image
                                            handler(image)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func goToOrderButton() {
        guard let backgroundButtonColor = UIColor(named: "darkRed") else { return }
        addOrderButton(buttonTitle: "Оформить заказ", backgroundColor: backgroundButtonColor, segueTo: "CartToCheckOut")
    }
    
    private func cartIsEmpty() {
        cartTable.setState(.withImage(image: UIImage(named: "logo"), title: "Корзина пуста :(", message: "Добавьте свои первые товары в корзину"))
        if let userUid = Auth.auth().currentUser?.uid {
            let docRef = Firestore.firestore().collection("users").document(userUid)
            deleteAllOutlet.removeFromSuperview()
            docRef.updateData([
                "cart": FieldValue.delete(),
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
        self.cartData.removeAll()
        cartStackView.isHidden = true
        addOrderButton(buttonTitle: "Перейти в меню", backgroundColor: .gray, segueTo: "CartToMain")
    }
    
    private func addOrderButton(buttonTitle: String, backgroundColor: UIColor, segueTo: String) {
        orderButton.setTitle(buttonTitle, for: .normal)
        orderButton.backgroundColor = backgroundColor
        orderButton.translatesAutoresizingMaskIntoConstraints = false
        orderButton.alpha = 0.8
        view.addSubview(orderButton)
        NSLayoutConstraint.activate([
            orderButton.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor),
            orderButton.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor),
            orderButton.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor,constant: -50),
            orderButton.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor),
            cartStackView.bottomAnchor.constraint(equalTo:orderButton.safeAreaLayoutGuide.topAnchor,constant: -20)
        ])
        orderButton.addAction(UIAction(handler: {_ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: segueTo, sender: self)
            }
        }), for: .touchUpInside)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CartToCheckOut" {
            guard let vc = segue.destination as? CheckOutViewController else { return }
            vc.cartData = cartData
        }
    }
}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as? cartTableViewCell else { return UITableViewCell() }
        cell.dishTitle.text = cartData[indexPath.row].dishTitle
        cell.dishPrice.text = "\(cartData[indexPath.row].price) ₴"
        cell.dishImage.layer.cornerRadius = cell.dishImage.frame.width / 20
        if let dishName = cell.dishTitle.text {
            loadImages(handler: { (image) -> Void in
                if let image = image {
                    DispatchQueue.main.async {
                        cell.dishImage.image = image
                    }
                }
            }, dish: dishName)
            
            cell.dishStepper.value = Float(cartData[indexPath.row].count)
            cell.dishStepper.countLabel.text = "\(cartData[indexPath.row].count)"
            cell.dishStepper.setButtonTextColor(UIColor(named: "darkRed"), for: .normal)
            cell.dishStepper.setBorderColor(.white)
            dishStepperAction(sender: cell.dishStepper, dish: dishName, dishPrice: cell.dishPrice)
        }
        return cell
    }
}
