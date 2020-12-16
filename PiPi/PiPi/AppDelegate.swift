//
//  AppDelegate.swift
//  PiPi
//
//  Created by 이가영 on 2020/10/16.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {
          self.window?.overrideUserInterfaceStyle = .light
        }
        
        return true
    }
}

