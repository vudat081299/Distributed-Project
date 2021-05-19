//
//  SignupInputCell.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 19/05/2021.
//

import UIKit

class SignupInputTableViewCell: UITableViewCell {
    static let reuseIdentifier = "SignupInputTableViewCell"
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var content: UITextField!
    var delegate: PassInputDataFromCell?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editingChangedContent(_ sender: UITextField) {
        delegate!.pass(sender.text ?? "", at: indexPath!)
    }
    
}
