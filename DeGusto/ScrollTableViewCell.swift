//
//  ScrollTableViewCell.swift
//  DeGusto
//
//  Created by Татьяна Серикова on 01.09.2021.
//

import UIKit

class ScrollTableViewCell: UITableViewCell {

    @IBOutlet weak var scrollCell: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
