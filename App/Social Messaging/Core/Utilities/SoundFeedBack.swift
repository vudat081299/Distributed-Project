//
//  SoundFeedBack.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 28/05/2021.
//

import Foundation
import AVFoundation

class SoundFeedBack {
    static let successFilePath = "payment_success"
    static let failFilePath = "payment_failure"
    static let fileExtension = "m4a"
    
    static var audioPlayer: AVAudioPlayer?
    
    
    
    static func success() {
        print("Play successful sound!")
        FeedBackTapEngine.tapped(style: .medium)
        guard let path = Bundle.main.path(forResource: successFilePath, ofType: fileExtension) else { return }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer!.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func fail() {
        print("Play failure sound!")
        FeedBackTapEngine.tapped(style: .medium)
        guard let path = Bundle.main.path(forResource: failFilePath, ofType: fileExtension) else { return }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer!.play()
        } catch {
            print(error.localizedDescription)
        }
    }
}
