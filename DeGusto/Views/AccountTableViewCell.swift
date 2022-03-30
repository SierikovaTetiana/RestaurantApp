//
//  AccountTableViewCell.swift
//  DeGusto
//
//  Created by Татьяна Серикова on 19.09.2021.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var updateButtonOutlet: UIButton!
    @IBAction func updateButton(_ sender: UIButton) {
    }
    @IBOutlet weak var labelInTable: UILabel!
    @IBOutlet weak var sysImageInTable: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
//    self.updateButtonOutlet.addTarget(self, action: #selector(updateButton(_:)), for: .touchUpInside)

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
