import SwiftData
import SwiftUI

struct AccountDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("accountsData") private var accountsData: Data?

    @State private var lastUpdated: Date? =
        UserDefaults.standard.object(forKey: "accountsLastUpdated") as? Date
    @StateObject private var networkManager = NetworkManager()
    @State private var isLoading = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else {
                List {
                    if let accountsData = accountsData,
                       let accounts = try? JSONDecoder().decode([Account].self, from: accountsData) {
                        ForEach(accounts, id: \.id) { account in
                            HStack {
                                Text(account.attributes.displayName)
                                Text(account.attributes.accountType)
                                Text(account.attributes.ownershipType)
                                Text(account.attributes.balance.value)
                            }
                        }
                    }
                }
            }
        }.onAppear {
            checkData()
        }
    }

    func checkData() {
        // Check if cached data exists
        if let data = accountsData, let timestamp = lastUpdated {
            // If data exists, check if it's older than 1 hour
            if Date().timeIntervalSince(timestamp) < 3600 {
                // Data is less than 1 hour old, use cached data
                if let cachedAccounts = try? JSONDecoder().decode([Account].self, from: data) {
                    networkManager.accounts = cachedAccounts
                }
            } else {
                // Data is more than 1 hour old, fetch new data
                fetchNewData()
            }
        } else {
            // No cached data, fetch new data
            fetchNewData()
        }
    }

    func fetchNewData() {
        isLoading = true
        networkManager.fetchAccounts { success in
            isLoading = false
            if success {
                // Save the new data and timestamp to UserDefaults
                if let encodedData = try? JSONEncoder().encode(networkManager.accounts) {
                    accountsData = encodedData
                    lastUpdated = Date()
                    UserDefaults.standard.set(lastUpdated, forKey: "accountsLastUpdated")
                }
            } else {
                // Handle error if needed
                print("Failed to fetch data.")
            }
        }
    }
}
