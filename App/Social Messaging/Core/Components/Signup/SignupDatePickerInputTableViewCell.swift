//
//  SignupDatePickerInputTableViewCell.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 19/05/2021.
//

import UIKit

class SignupDatePickerInputTableViewCell: UITableViewCell {
    static let reuseIdentifier = "SignupDatePickerInputTableViewCell"
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var datePickerView: UIDatePicker!
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
    @IBAction func didPickDate(_ sender: UIDatePicker) {
        delegate!.pass(sender.date.iso8601String, at: indexPath!)
    }
    
}
