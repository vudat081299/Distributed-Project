import App

// MARK: - Making app.
// Method 1.
import Vapor
//print("Hello, world!")
//var env = try Environment.detect()
//try LoggingSystem.bootstrap(from: &env)
//let app = Application(env)
//defer { app.shutdown() }
//try configure(app)
//try app.run()

// Method 2.
// Refer: /Users/vudat81299/Desktop/EnableDelete/hello/Sources/App/MongoDB/App.swift
try makeApp().run()

// Learn SwiftPM.
//if CommandLine.arguments.count != 2 {
//    print("Usage: hello NAME")
//} else {
//    let name = CommandLine.arguments[1]
//    sayHello(name: name)
//}
//func sayHello(name: String) {
//    print("Hello, \(name)!")
//}
