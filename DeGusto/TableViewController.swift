//
//  TableViewController.swift
//  DeGusto
//
//  Created by Татьяна Серикова on 31.08.2021.
//

import UIKit

class TableViewController: UITableViewController {

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
        let cell = tableView.dequeueReusableCell(withIdentifier: "dishCell", for: indexPath)
//        let imageName = UIImage(named: "logo")
//        cell.imageView?.image = imageName
        return cell
    }
    
}
