import SwiftData
import SwiftUI

/// The main content view of the application.
struct SplitViewNavigation: View {
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

#Preview(traits: .fixedLayout(width: 800, height: 400)) {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Account.self, configurations: config)
    
    // Create sample accounts
    let account1 = Account(
        type: "accounts",
        id: "1",
        attributes: AccountAttributes(
            displayName: "💰 Everyday Account",
            accountType: "TRANSACTIONAL",
            ownershipType: "INDIVIDUAL",
            balance: Balance(currencyCode: "AUD", value: "2750.50", valueInBaseUnits: 275050),
            createdAt: "2023-01-15T10:30:00Z"
        ),
        transactionLink: "https://api.up.com.au/api/v1/accounts/1/transactions"
    )
    
    let account2 = Account(
        type: "accounts",
        id: "2",
        attributes: AccountAttributes(
            displayName: "🏠 Home Loan",
            accountType: "HOME_LOAN",
            ownershipType: "INDIVIDUAL",
            balance: Balance(currencyCode: "AUD", value: "-450000.00", valueInBaseUnits: -45000000),
            createdAt: "2022-06-01T09:00:00Z"
        ),
        transactionLink: "https://api.up.com.au/api/v1/accounts/2/transactions"
    )
    
    let account3 = Account(
        type: "accounts",
        id: "3",
        attributes: AccountAttributes(
            displayName: "🎯 Savings Goal",
            accountType: "SAVER",
            ownershipType: "INDIVIDUAL",
            balance: Balance(currencyCode: "AUD", value: "15000.75", valueInBaseUnits: 1500075),
            createdAt: "2023-03-20T14:45:00Z"
        ),
        transactionLink: "https://api.up.com.au/api/v1/accounts/3/transactions"
    )
    
    // Insert sample data into the container
    container.mainContext.insert(account1)
    container.mainContext.insert(account2)
    container.mainContext.insert(account3)
    
    return SplitViewNavigation()
        .modelContainer(container)
}
