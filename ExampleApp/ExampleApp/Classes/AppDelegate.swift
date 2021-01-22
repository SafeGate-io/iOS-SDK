//
//  AppDelegate.swift
//  ExampleApp
//
//  Created by Kirill Budevich on 11/18/20.
//

import UIKit
import SafeGateSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        setupLogging()
        
        return true
    }
    
    func setupLogging() {
        SafeGateSDK.Logger.logLevel = .debug
        SafeGateSDK.Logger.instance = PrintLogger()
    }
}
