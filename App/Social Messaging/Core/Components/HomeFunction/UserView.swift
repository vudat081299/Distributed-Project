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
    }
    
    @IBAction func followAction(_ sender: UIButton) {
        if let action = followActionClosure {
            action()
        }
    }
    
    @IBAction func messToUserAction(_ sender: UIButton) {
        print(Auth.userProfileData)
        if let action = messToUserActionClosure {
            action()
        }
        if userProfileData != nil {
            let currentUser = Auth.userProfileData
            let members = [userProfileData?.idOnRDBMS]
            let id1 = currentUser?.idOnRDBMS.uuidString
            let id2 = userProfileData?.idOnRDBMS.uuidString
            let members_id = [currentUser?._id, userProfileData?._id]
            
            let dateFormatter = DateFormatter()
            let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
            dateFormatter.locale = enUSPosixLocale
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            dateFormatter.calendar = Calendar(identifier: .gregorian)

            let iso8601String = dateFormatter.string(from: Date())
            let generatedString = id1! > id2! ? "\(id1)\(id2)" : "\(id2)\(id2)"
            
            let box = Box(
                generatedString: generatedString,
                type: .privateChat,
                members: members,
                members_id: members_id,
                creator_id: currentUser?._id,
                createdAt: iso8601String
            )
            let request = ResourceRequest<Box>(resourcePath: "mess/box")
            request.post(token: Auth.token, box) { result in
                switch result {
                case .success(let data):
                    break
                case .failure:
                    break
                }
            }
        }
    }
    
}
