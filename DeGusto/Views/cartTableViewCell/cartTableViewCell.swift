//
//  cartTableViewCell.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 18.11.2021.
//

import UIKit
import PKYStepper

class cartTableViewCell: UITableViewCell {

    @IBOutlet weak var dishPrice: UILabel!
    @IBOutlet weak var dishStepper: PKYStepper!
    @IBOutlet weak var dishTitle: UILabel!
    @IBOutlet weak var dishImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
