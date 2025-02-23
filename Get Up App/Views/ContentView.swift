//
//  ContentView.swift
//  Get Up App
//
//  Created by Emma Puls on 22/2/2025.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Environment(\.openSettings) private var openSettings

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    Text("Accounts")
                } label: {
                    // The label should be the bankAPI from AppStorage + " Accounts"
                    Text((UserDefaults.standard.string(forKey: "bankAPI") ?? "Up") + " Accounts")
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        openSettings()
                    }) {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
        } detail: {
            AccountDetailsView()
        }
    }

    
}

#Preview {
    ContentView()
}
