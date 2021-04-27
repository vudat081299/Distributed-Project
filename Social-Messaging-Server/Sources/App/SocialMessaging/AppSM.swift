//
//  AppSM.swift
//  
//
//  Created by Vũ Quý Đạt  on 25/04/2021.
//

import Vapor



// MARK: - App.
public func makeSMApp() throws -> Application {
    let app = Application()
    try configureSM(app)
    

    
//    a() {
//        print("11111")
//    } c: {
//        print("22222")
//    }()
    
    return app
}

func a (b: @escaping () -> (), c: @escaping () -> ()) -> (() -> ()) {
    b()
    c()
    return { print("33333") }
}



// MARK: - Context.



