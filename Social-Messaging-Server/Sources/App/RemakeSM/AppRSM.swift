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
    return app
}
