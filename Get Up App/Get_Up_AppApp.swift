//
//  Get_Up_AppApp.swift
//  Get Up App
//
//  Created by Emma Puls on 22/2/2025.
//

import SwiftData
import SwiftUI

@main
struct Get_Up_AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Account.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplitViewNavigation()
        }
        .modelContainer(sharedModelContainer)
        Settings {
            SettingsView()
        }
    }
}
