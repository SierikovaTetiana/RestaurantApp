//
//  dishTableViewCell.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 31.08.2021.
//

import UIKit
import FaveButton
import PKYStepper

class dishTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stackViewAddDish: UIStackView!
    @IBOutlet weak var addDish: UIButton!
    @IBOutlet weak var dishImage: UIImageView!
    @IBOutlet weak var stackViewDishImage: UIStackView!
    @IBOutlet weak var descriptionDish: UILabel!
    @IBOutlet weak var titleDish: UILabel!
    @IBOutlet weak var priceDish: UILabel!
    @IBOutlet weak var weightDish: UILabel!
    
    let faveButton = FaveButton(
        frame: CGRect(x:UIScreen.main.bounds.size.width - 70, y:0, width: 44, height: 44),
        faveIconNormal: UIImage(systemName: "heart.circle")
    )
    let stepper = PKYStepper(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setNeedsLayout() {
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
            UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            self.faveButton.frame = CGRect(x:UIScreen.main.bounds.size.width - 100, y:0, width: 44, height: 44)
            self.stepper.frame = CGRect(x: self.bounds.width - 295, y: 0, width: 120, height: 30)
        } else {
            self.faveButton.frame = CGRect(x:UIScreen.main.bounds.size.width - 70, y:0, width: 44, height: 44)
            self.stepper.frame = CGRect(x: self.bounds.width - 220, y: 0, width: 120, height: 30)
        }
    }
}
