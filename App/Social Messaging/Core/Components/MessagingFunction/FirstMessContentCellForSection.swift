//
//  FirstMessContentCellForSection.swift
//  Social Messaging
//
//  Created by Dat vu on 22/04/2021.
//

import UIKit

class FirstMessContentCellForSection: UICollectionViewCell {
    static let reuseIdentifier = "FirstMessContentCellForSection"
    
    @IBOutlet weak var contentTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var creationDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        constraint.constant = 0
    }
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                backGroundView.backgroundColor = .systemBackground
                // Your customized animation or add a overlay view
            } else {
                backGroundView.backgroundColor = .clear
                // Your customized animation or remove overlay view
            }
        }
    }
}
