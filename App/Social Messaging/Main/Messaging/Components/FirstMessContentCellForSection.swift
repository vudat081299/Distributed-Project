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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        constraint.constant = 0
    }
}
