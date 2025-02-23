import SwiftData
import SwiftUI

/// A view that displays the details of accounts.
struct AccountDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("accountsData") private var accountsData: Data?

    @State private var lastUpdated: Date? =
        UserDefaults.standard.object(forKey: "accountsLastUpdated") as? Date
    @StateObject private var networkManager = NetworkManager()
    @State private var isLoading = false

    /// Decodes the accounts data from UserDefaults.
    var decodedAccounts: [Account]? {
        if let accountsData = accountsData {
            return try? JSONDecoder().decode([Account].self, from: accountsData)
        }
        return nil
    }

    /// Calculates the maximum width of the balance strings for proper alignment.
    var maxWidthOfBalance: CGFloat {
        guard let accounts = decodedAccounts else { return 0 }
        var widthArray: [CGFloat] = []
        for account in accounts {
            let widthOfBalance = account.attributes.balance.value.widthOfString(
                usingFont: NSFont.systemFont(ofSize: 14))
            widthArray.append(widthOfBalance)
        }
        return widthArray.max() ?? 0
    }

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
                                Text(account.attributes.emoji ?? "").frame(maxWidth: 24)
                                Text(account.attributes.modifiedDisplayName ?? account.attributes.displayName).frame(maxWidth: .infinity, alignment: .leading)
                                Text(account.attributes.accountType).frame(maxWidth: .infinity, alignment: .leading)
                                Text(account.attributes.ownershipType).frame(maxWidth: .infinity, alignment: .leading)
                                Text(account.attributes.balance.value).frame(maxWidth: maxWidthOfBalance, alignment: .trailing)
                            }
                        }
                    }
                }.padding(16)
            }
        }.onAppear {
            checkData()
        }
    }

    /// Checks if cached data exists and if it is still valid.
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

    /// Fetches new data from the network and updates the cache.
    func fetchNewData() {
        isLoading = true
        networkManager.fetchAccounts { result in
            isLoading = false
            switch result {
            case .success:
                // Save the new data and timestamp to UserDefaults
                if let encodedData = try? JSONEncoder().encode(networkManager.accounts) {
                    accountsData = encodedData
                    lastUpdated = Date()
                    UserDefaults.standard.set(lastUpdated, forKey: "accountsLastUpdated")
                }
            case .failure(let error):
                // TODO: Handle errors properly with feedback to the user
                print("Failed to fetch accounts: \(error.localizedDescription)")
            }
        }
    }
}
