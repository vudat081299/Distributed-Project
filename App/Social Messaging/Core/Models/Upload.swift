//
//  Upload.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 12/12/2020.
//

import Foundation
import CoreLocation

final class AnnotationA: Codable {
    var annotationImageName: String
    var image: String
    
    init(annotationImageName: String, image: String) {
        self.annotationImageName = annotationImageName
        self.image = image
    }
}

final class AnnotationUpload: Codable {
    var title: String
    var subTitle: String?
    var latitude: String
    var longitude: String
    var description: String?
    var image: [File]?
//    var type: String? = String(TypeAnnotation.publibPlace.rawValue)
    var type: String?
    var imageNote: String?
    
    init(title: String, subTitle: String, latitude: String, longitude: String, description: String, type: String, imageNote: String, image: [File], city: String, country: String) {
        self.title = title
        self.subTitle = subTitle
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.type = type
        self.imageNote = imageNote
        self.image = image
        self.city = city
        self.country = country
    }
    
    var country: String?
    var city: String?
}

final class AnnotationInfo: Codable {
    var id: Int
    var latitude: String
    var longitude: String
    var name: String
    var description: String
    
    init(id: Int, latitude: String, longitude: String, name: String, description: String) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.description = description
    }
}

final class CheckTotalOfAnnotationsReponse: Codable {
    var shouldUpdate: Bool
    init(shouldUpdate: Bool) {
        self.shouldUpdate = shouldUpdate
    }
}

final class CreateUserFormData: Codable {
    var id: UUID?
    var name: String?
    var username: String
    var password: String?
    var email: String?
    var phonenumber: String?
    
    init(name: String, username: String, password: String, email: String, phonenumber: String) {
        self.name = name
        self.username = username
        self.password = password
        self.email = email
        self.phonenumber = phonenumber
    }
}

struct ResponseCreateUser: Codable {
    let code: Int
    let message: String
    let data: UserInfoForm
}

struct UserInfoForm: Codable {
    var id: String?
    var name: String?
    var username: String
    var email: String?
    var phonenumber: String?
}

final class AnnotatioImageData: Codable {
    var annotationImageName: String
    var image: String
    
    init(annotationImageName: String, image: String) {
        self.annotationImageName = annotationImageName
        self.image = image
    }
}
