//
//  File.swift
//  
//
//  Created by Vũ Quý Đạt  on 14/03/2021.
//

//import Foundation
// Reference: SPM docs.

print("Test SwiftPM.")

if CommandLine.arguments.count != 2 {
    print("Usage: hello NAME")
} else {
    let name = CommandLine.arguments[1]
    sayHello(name: name)
    print(CommandLine.arguments)
}
// cd to working path and try in terminal $ swift run TestSwiftPM `whoami`

func sayHello(name: String) {
    print("Hello, \(name)!")
}
