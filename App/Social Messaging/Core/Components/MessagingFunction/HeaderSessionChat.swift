//
//  HeaderSessionChat.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 21/04/2021.
//

import UIKit

class HeaderSessionChat: UICollectionReusableView {
    static let reuseIdentifier = "HeaderSessionChat"
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        constraint.constant = 0
        avatar.image = nil
    }
}

extension HeaderSessionChat {
    func configure() {
    }
}

