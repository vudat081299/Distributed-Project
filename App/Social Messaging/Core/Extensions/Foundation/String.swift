//
//  String.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 19/05/2021.
//

import Foundation
import UIKit

extension String {
    
    /// Convert from date String to shortTime String.
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
    
    func getImageWithThisURL() -> UIImage? {
        print("Get image with url string: \(self)")
        do {
            return UIImage(data: try Data(contentsOf: URL(string: self)!))
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
