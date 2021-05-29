//
//  MessContentCell.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 21/04/2021.
//

import UIKit

class MessContentCell: UICollectionViewCell {
    static let reuseIdentifier = "MessContentCell"
    
    @IBOutlet weak var contentTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        constraint.constant = 0
    }

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                backgroundColor = .systemBackground
                // Your customized animation or add a overlay view
            } else {
                backgroundColor = .clear
                // Your customized animation or remove overlay view
            }
        }
    }

}
