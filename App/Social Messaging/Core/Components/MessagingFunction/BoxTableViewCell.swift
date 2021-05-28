//
//  BoxTableViewCell.swift
//  Social Messaging
//
//  Created by Dat vu on 13/05/2021.
//

import UIKit

class BoxTableViewCell: UITableViewCell {
    static let reuseIdentifier = "BoxTableViewCell"
    
    @IBOutlet weak var boxImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var lastestMess: UILabel!
    @IBOutlet weak var timeStampButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        boxImage.image = nil
    }
    
}
