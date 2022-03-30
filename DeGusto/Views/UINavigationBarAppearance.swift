//
//  UINavigationBarAppearance.swift
//  DeGusto
//
//  Created by Татьяна Серикова on 22.09.2021.
//

import UIKit

class UINavigationBarAppearance: UIBarAppearance {

    let navigationBar = UINavigationBar()
    
//    @available(iOS 13.0, *)
    func setupDefaultNavigationBarAppearance() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
//            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor.white
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
    
    
//    if #available(iOS 13.0, *) {
//        let navBarAppearance = UINavigationBarAppearance()
//        navBarAppearance.configureWithOpaqueBackground()
//        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        navBarAppearance.backgroundColor = UIColor.white
//        navigationBar.standardAppearance = navBarAppearance
//        navigationBar.scrollEdgeAppearance = navBarAppearance
//    }
//
}
