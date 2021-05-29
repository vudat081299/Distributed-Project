//
//  AvatarViewerAndPickerTableViewCell.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 28/05/2021.
//

import UIKit

class AvatarViewerAndPickerTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AvatarViewerAndPickerTableViewCell"
    
    @IBOutlet weak var avatar: UIImageView!
    var changeProfilePhotoClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        avatar.borderOutline(0.5, color: .lightGray)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func changeProfilePhotoPressed(_ sender: UIButton) {
        changeProfilePhotoClosure!()
    }
    
}
