//
//  ViewController.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 25.08.2021.
//

import UIKit
import MapKit
import Firebase

class MapViewController: UIViewController {
    
    @IBOutlet weak var textMap: UITextView!
    @IBAction func cartButton(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "MapToCart", sender: self)
        }
    }
    
    @IBAction func profileButton(_ sender: UIBarButtonItem) {
        if Auth.auth().currentUser == nil || Auth.auth().currentUser!.isAnonymous {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "MapToProfile", sender: self)
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "MapToAccount", sender: self)
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    var cartData: [CartData] {
        if let mainVC = navController?.viewControllers[0] as? MainViewController {
            return mainVC.cartData
        } else {
            return [CartData]()
        }
    }
    
    var sections: [SectionData] {
        if let mainVC = navController?.viewControllers[0] as? MainViewController {
            return mainVC.sections
        } else {
            return [SectionData]()
        }
    }
    
    private lazy var navController = tabBarController?.viewControllers?[0] as? UINavigationController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPinUsingMKPlacemark()
    }
    
    private func setPinUsingMKPlacemark() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 50.015519693946075, longitude: 36.22190427116375)
        annotation.title = "De Gusto"
        annotation.subtitle = "ул.Космическая, 16"
        let pin = MKPlacemark(coordinate: annotation.coordinate)
        let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
        textMap.text = "📍Город Харьков. Улица Космическая, 16. ☎️"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapToCart" {
            guard let  vc = segue.destination as? CartViewController else { return }
            vc.sections = sections
            vc.cartData = cartData
        } else if segue.identifier == "MapToAccount" {
            guard let vc = segue.destination as? AccountViewController else { return }
            vc.sections = sections
            vc.cartData = cartData
        }
    }
}
