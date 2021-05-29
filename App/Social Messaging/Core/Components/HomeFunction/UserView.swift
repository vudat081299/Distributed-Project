//
//  UserView.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 11/05/2021.
//

import UIKit

class UserView: UICollectionViewCell {
    static let reuseIdentifier = "UserView"
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messButton: UIButton!
    @IBOutlet weak var bio: UILabel!
    var followActionClosure: (() -> Void)?
    var userProfileData: User?
    var messToUserActionClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatar.image = nil
    }
    
    @IBAction func followAction(_ sender: UIButton) {
        FeedBackTapEngine.tapped(style: .medium)
        if let action = followActionClosure {
            action()
        }
    }
    
    @IBAction func messToUserAction(_ sender: UIButton) {
        FeedBackTapEngine.tapped(style: .medium)
        if let action = messToUserActionClosure {
            action()
        }
    }
    
}
