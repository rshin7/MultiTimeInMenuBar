//
//  MultiTimeInMenuBarApp.swift
//  MultiTimeInMenuBar
//
//  Created by Richard Shin on 4/6/25.
//

import SwiftUI

@main
struct MultiTimeInMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No regular window needed
        Settings {
            EmptyView()
        }
    }
}
