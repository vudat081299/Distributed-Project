//
//  SignupPickerInputTableViewCell.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 19/05/2021.
//

import UIKit

class SignupPickerInputTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    static let reuseIdentifier = "SignupPickerInputTableViewCell"
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    var itemsOfPickerView: [String]!
    var delegate: PassInputDataFromCell?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pickerView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let list = itemsOfPickerView else {
            return 0
        }
        return list.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return itemsOfPickerView[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate!.pass("\(row)", at: indexPath!)
    }
}
