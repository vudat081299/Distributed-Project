//
//  CustomCollectionViewListCell.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 14/04/2021.
//

import UIKit

class CustomCollectionViewListCell: UICollectionViewCell {
    static let reuseIdentifier = "CustomCollectionViewListCell"
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

//
//class CustomCollectionViewListCell: UICollectionViewCell {
//
//    let icon: UIImageView = {
//        let icon = UIImageView(image: UIImage(named: "avatar"))
//        icon.frame.size = CGSize(width: 30, height: 30)
//        return icon
//    }()
//    var textLabel = UILabel()
//    static let reuseIdentifier = "CustomCollectionViewListCell"
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configure()
//    }
//    required init?(coder: NSCoder) {
//        fatalError("not implemnted")
//    }
//}
//
//extension CustomCollectionViewListCell {
//    func configure() {
//        textLabel.translatesAutoresizingMaskIntoConstraints = false
//        textLabel.adjustsFontForContentSizeCategory = true
//        contentView.addSubview(textLabel)
//        contentView.addSubview(icon)
//        textLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
//        let inset = CGFloat(10)
//        NSLayoutConstraint.activate([
//            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
//            icon.trailingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: -inset),
//            icon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
//
//            textLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: inset),
//            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
//            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
//            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
//        ])
//    }
//}
//
