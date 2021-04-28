//
//  File.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Vapor



// MARK: - App.
public func makeRSMApp() throws -> Application {
    let app = Application()
    try configureRSM(app)
    

    
//    a() {
//        print("11111")
//    } c: {
//        print("22222")
//    }()
    
    return app
}
