import App
import Vapor



// MARK: - Making app - Entrance file for app.



// Method 1.
// MARK: - TILApp.
// Ref: https://github.com/raywenderlich/vapor-til.git
//print("Hello, world!")
//var env = try Environment.detect()
//try LoggingSystem.bootstrap(from: &env)
//let app = Application(env)
//defer { app.shutdown() }
//try configure(app)
//try app.run()



// Method 2.
// MARK: - MonggoDB app.
// Ref: https://www.raywenderlich.com/10521463-server-side-swift-with-mongodb-getting-started
// Refer: /Users/vudat81299/Desktop/EnableDelete/hello/Sources/App/MongoDB/App.swift
//try makeApp().run()

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



// MARK: - Social Messaging app.
//try makeSMApp().run()



// MARK: - RSMApp.
try makeRSMApp().run()
