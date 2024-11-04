//
//  LiWakeApp.swift
//  LiWake
//
//  Created by Qiandao Liu on 11/1/24.
//

import SwiftUI

@main
struct LiWakeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // 关联 AppDelegate

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
