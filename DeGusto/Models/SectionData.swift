//
//  SectionData.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 07.09.2021.
//

import UIKit

class SectionData {
    var open : Bool
    var data : [CellData] = []
    var order : Int
    
    init(open: Bool, data: [CellData], order: Int) {
              self.open = open
              self.data = data
              self.order = order
         }
}

class CellData {
    var title : String = ""
    var sectionImage : UIImage?
    var sectionImgName : String = ""
    var cellData : [DishData] = []
    
    init(title: String, image: UIImage?, sectionImgName: String, cellData: [DishData]) {
              self.title = title
              self.sectionImage = image
              self.sectionImgName = sectionImgName
              self.cellData = cellData
         }
}

class DishData {
    var dishTitle : String = ""
    var dishImage : UIImage?
    var dishImgName : String = ""
    var description : String = ""
    var weight : Int = 0
    var price : Int = 0
    var favorite : Bool = false
    var cartCount : Int = 0
    
    init(dishTitle: String, dishImage: UIImage?, dishImgName: String, description: String, weight: Int, price: Int, favorite: Bool, cartCount: Int) {
              self.dishTitle = dishTitle
              self.dishImage = dishImage
              self.dishImgName = dishImgName
              self.description = description
              self.weight = weight
              self.price = price
              self.favorite = favorite
              self.cartCount = cartCount
         }
}

class CartData {
    var dishTitle : String = ""
    var count : Int = 0
    var price : Int = 0
    
    init(dishTitle: String, count: Int, price: Int) {
              self.dishTitle = dishTitle
              self.count = count
              self.price = price
         }
}

class OrderPersonData {
    var takeAway : Bool = true
    var deliveryAddress : String = ""
    var name : String = ""
    var phone : String = ""
    var comment : String = ""
    var time : Date
    var userID : String = ""
    
    init(takeAway: Bool, deliveryAddress: String, name: String, phone: String, comment: String, time: Date, userID: String) {
            self.takeAway = takeAway
            self.deliveryAddress = deliveryAddress
            self.name = name
            self.phone = phone
            self.comment = comment
            self.time = time
            self.userID = userID
         }
}
