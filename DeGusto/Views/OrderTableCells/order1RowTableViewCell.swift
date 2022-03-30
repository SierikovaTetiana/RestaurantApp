//
//  order1RowTableViewCell.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 22.11.2021.
//

import UIKit
import IQKeyboardManagerSwift

class order1RowTableViewCell: UITableViewCell {

    @IBOutlet weak var orderPersonalStackView: UIStackView!
    @IBOutlet weak var orderPersonalName: UITextField!
    @IBOutlet weak var orderPersonalPhone: UITextField!
    @IBOutlet weak var addressStackView: UIStackView!
    @IBOutlet weak var orderPersonalAddress: UITextField!
    @IBOutlet weak var orderPersonalAddressImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
