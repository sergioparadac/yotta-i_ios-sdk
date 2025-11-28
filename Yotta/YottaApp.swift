//
//  YottaApp.swift
//  Yotta
//
//  Created by Pedro Lacoste on 27-11-25.
//

import SwiftUI

@main
struct MySNIVPNApp: App {
    // Vinculamos el AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
