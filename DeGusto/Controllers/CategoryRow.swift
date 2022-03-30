//
//  CategoryRowTableViewCell.swift
//  DeGusto
//
//  Created by Tetiana Sierikova on 02.09.2021.
//

import UIKit
import Firebase

class CategoryRow: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectView: UICollectionView!
    
    var scroll_timer : Timer?
    private let storage = Storage.storage()
    private var x = 1
    private var img: [UIImage] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        getImagesForSlider(handler: { (image) -> Void in })
    }
    
    @objc private func autoScroll() {
        let indexPath = IndexPath(item: x, section: 0)
        collectView.scrollToItem(at: indexPath, at: .right, animated: true)
        self.x += 1
    }
    
    func setTimer() {
        scroll_timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if !img.isEmpty {
            let imgView = UIImageView(image: img[indexPath.row % img.count])
            imgView.frame.size = cell.frame.size
            imgView.contentMode = UIView.ContentMode.scaleAspectFill
            imgView.layer.masksToBounds = true
            cell.contentView.addSubview(imgView)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10000
    }
    
    private func getImagesForSlider (handler: @escaping (_ image : UIImage?) -> Void) {
        let storageReference = storage.reference().child("sliderImages")
        storageReference.listAll { (result, error) in
            if let error = error {
                print("Error: ", error)
            }
            for item in result.items {
                let storageRef = self.storage.reference().child("sliderImages/\(item.name)")
                storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        handler(nil)
                        print("Uh-oh, an error occurred in CategoryRow func getImagesForSlider!", error)
                    } else {
                        if let imgData = data {
                            if let image = UIImage(data: imgData) {
                                self.img.append(image)
                                handler(image)
                            }
                        }
                    }
                    self.collectView?.reloadData()
                }
            }
        }
    }
}
