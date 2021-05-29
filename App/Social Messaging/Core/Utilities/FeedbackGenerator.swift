//
//  FeedbackGenerator.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 18/05/2021.
//

import UIKit

struct FeedBackTapEngine {
    static func tapped(style: UIImpactFeedbackGenerator.FeedbackStyle?, type: UINotificationFeedbackGenerator.FeedbackType? = .success) {
        
        if let feedbackStyle = style {
            let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
            generator.impactOccurred()
            return
        }
        
        if let feedbackType = type {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(feedbackType)
            return
        }
        
        //    switch type {
        //    case 1:
        //        let generator = UINotificationFeedbackGenerator()
        //        generator.notificationOccurred(.error)
        //
        //    case 2:
        //        let generator = UINotificationFeedbackGenerator()
        //        generator.notificationOccurred(.success)
        //
        //    case 3:
        //        let generator = UINotificationFeedbackGenerator()
        //        generator.notificationOccurred(.warning)
        //
        //    case 4:
        //        let generator = UIImpactFeedbackGenerator(style: .light)
        //        generator.impactOccurred()
        //
        //    case 5:
        //        let generator = UIImpactFeedbackGenerator(style: .medium)
        //        generator.impactOccurred()
        //
        //    case 6:
        //        let generator = UIImpactFeedbackGenerator(style: .heavy)
        //        generator.impactOccurred()
        //
        //    default:
        //        let generator = UISelectionFeedbackGenerator()
        //        generator.selectionChanged()
        //    }
    }
}
