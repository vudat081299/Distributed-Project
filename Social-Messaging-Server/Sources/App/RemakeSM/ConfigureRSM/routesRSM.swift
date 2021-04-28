//
//  File.swift
//  
//
//  Created by Vũ Quý Đạt  on 28/04/2021.
//

import Vapor

func routesRSM(_ app: Application) throws {

    let usersControllerRSM = UsersControllerRSM()
    try app.register(collection: usersControllerRSM)

}
