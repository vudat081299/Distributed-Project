//
//  ProfileInfoDataTableViewCell.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 28/05/2021.
//

import UIKit

class ProfileInfoDataTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ProfileInfoDataTableViewCell"
    @IBOutlet weak var tilteLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var separator: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
