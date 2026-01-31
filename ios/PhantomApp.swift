//
//  PhantomApp.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

@main
struct PhantomApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                DashboardView()
            } else {
                LoginView()
            }
        }
    }
}
