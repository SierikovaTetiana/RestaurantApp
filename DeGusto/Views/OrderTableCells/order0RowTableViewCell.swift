//
//  order0RowTableViewCell.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 22.11.2021.
//

import UIKit

class order0RowTableViewCell: UITableViewCell {

    @IBOutlet weak var takeAway: UISegmentedControl!
    
    @IBAction func takeAwayAction(_ sender: UISegmentedControl) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
