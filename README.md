# 🍕RestaurantApp
 Restaurant food order app. Swift 5. Xcode 13.2. iOS 15. 

## 📷 Screenshots

![MockupDeGusto](https://user-images.githubusercontent.com/75028505/160867191-5306265f-4fd8-4373-a823-5567d48d2c1a.jpg)

## 🔖 Features: 
- Restaurant menu:
  -  show top discount section with infinite scroll by timer 
  -  with show/hide dishes in categories
  -  dish can be added to favorite list (appears when dish added and dissappears when all dishes removed from list)
  -  dish can be added to cart
- Map:
  -  display map with pin
- Account profile:
  -  register user by email-password or/and Facebook
  -  user can upload photo to profile
  -  user can set and change profile information: name, birth date, phone number, password, email (integrated with Firestore Database)
- Cart:
  -  user can change amount of dishes or remove all of it
- Order process:
  -  if user is registered in app all information fill fields
  -  user can choose take away or delivery
  -  if user selects delivery, address field is displayed (required for order)
  -  GooglePlaces helps fill user valid address
  -  required name and phone number fields
  -  app checks if user enter valid information in fields (phone, name, address)
  -  user can select time for delivery or ready to take away
  -  order button sends information about order to Database
  -  simple app written in Python sends email with order

## 💻 Technologies:
- Firebase Authentication
- Firebase Realtime Database
- Firebase Storage
- Firestore Database
- Facebook Authentication
- GooglePlaces
- MapKit
- Core Data

#### Pods:
- DatePickerDialog
- PhoneNumberKit
- NotificationBannerSwift
- ReachabilitySwift
- FaveButton
- PKYStepper
- SDStateTableView
- IQKeyboardManagerSwift

Images and menu text from [DeGusto](https://degustotrattoria.kh.ua/)
