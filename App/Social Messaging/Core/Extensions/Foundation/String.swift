//
//  String.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 19/05/2021.
//

import Foundation

extension String {
    func transformToShortTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        guard let date = dateFormatter.date(from: self)
        else {
            return ""
        }
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: date)
    }
}
