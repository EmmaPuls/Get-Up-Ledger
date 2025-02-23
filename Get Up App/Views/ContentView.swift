import SwiftData
import SwiftUI

/// The main content view of the application.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openSettings) private var openSettings

    /// Represents a navigation title with an ID and title.
    struct NavigationTitle: Identifiable {
        var id: String
        var title: String
    }

    let navigationTitles: [NavigationTitle] = [NavigationTitle(id: "1", title: "Accounts")]
    @State private var selection: String? = nil

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(navigationTitles) { navigationTitle in
                    NavigationLink {
                        AccountDetailsView()
                    } label: {
                        Label {
                            Text(navigationTitle.title)
                        } icon: {
                            Circle().frame(width: 12, height: 12, alignment: .center)
                        }
                    }
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
