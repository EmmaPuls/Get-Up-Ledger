import SwiftData
import SwiftUI

/// A view that displays the details of accounts.
struct AccountDetailsView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var lastUpdated: Date? =
        UserDefaults.standard.object(forKey: "accountsLastUpdated") as? Date
    @StateObject private var networkManager = NetworkManager()
    @State private var isLoading = false
    @State private var error: String?

    /// Calculates the maximum width of the balance strings for proper alignment.
    var maxWidthOfBalance: CGFloat {
        let accounts = networkManager.accounts
        var widthArray: [CGFloat] = []
        for account in accounts {
            let widthOfBalance = account.attributes.balance.toString().widthOfString(
                usingFont: NSFont.systemFont(ofSize: 14))
            widthArray.append(widthOfBalance)
        }
        return widthArray.max() ?? 0
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if error != nil {
                Text("An error occured fetching account data").bold().padding(.vertical)
                    .accessibilityHeading(AccessibilityHeadingLevel.h1)
                Text(error!)
            } else {
                List {
                    if !networkManager.accounts.isEmpty {
                        ForEach(networkManager.accounts, id: \.id) { account in
                            HStack {
                                Text(account.attributes.emoji ?? "").frame(maxWidth: 24)
                                Text(
                                    account.attributes.modifiedDisplayName
                                        ?? account.attributes.displayName
                                ).frame(maxWidth: .infinity, alignment: .leading)
                                Text(account.attributes.accountType).frame(
                                    maxWidth: .infinity, alignment: .leading)
                                Text(account.attributes.ownershipType).frame(
                                    maxWidth: .infinity, alignment: .leading)
                                Text(account.attributes.balance.toString()).frame(
                                    maxWidth: maxWidthOfBalance, alignment: .trailing)
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
        if !networkManager.accounts.isEmpty, let timestamp = lastUpdated {
            // If data exists, check if it's older than 1 hour
            if Date().timeIntervalSince(timestamp) < 0, !networkManager.accounts.isEmpty {
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
                print(networkManager.accounts)
                // Save the timestamp
                lastUpdated = Date()
                UserDefaults.standard.set(lastUpdated, forKey: "accountsLastUpdated")

            case .failure(let error):
                // If error is of type NetworkError.httpError(401)
                if case NetworkError.httpError(let statusCode) = error, statusCode == 401 {
                    self.error = "Unauthorized: Please check your API key."
                } else {
                    self.error = error.localizedDescription
                }
                print("Failed to fetch accounts: \(error.localizedDescription)")
            }
        }
    }
}
