//
//  CollectionViewCell.swift
//  DeGusto
//
//  Created by Татьяна Серикова on 02.09.2021.
//

import UIKit

class CollectionViewCell: UITableViewCell {
    @IBOutlet weak var cell: UICollectionViewCell!
    @IBOutlet weak var collectView: UICollectionView!
    // UITableViewCell
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let nibName = UINib(nibName: "ClassCollectionCell", bundle:nil)
        collectView.register(nibName, forCellWithReuseIdentifier: "cell")
        }
    

}
