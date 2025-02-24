import SwiftUI

/// A view that displays the transactions of an account.
struct AccountTransactionsView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var networkManager = NetworkManager()
    @State private var isLoading = false
    @State private var isGettingNextPage = false
    @State private var error: Error?
    @State private var nextPageURL: String?
    let account: Account

    var body: some View {
        VStack {
            if isLoading {
                LoadingView()
            } else if let error = error {
                NetworkErrorView(error: error)
            } else {
                List {
                    if !networkManager.currentTransactions.isEmpty {
                        ForEach(networkManager.currentTransactions, id: \.id) { transaction in
                            HStack {
                                Text(transaction.attributes.description)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(transaction.attributes.performingCustomer?.displayName ?? "")
                                Text(transaction.attributes.amount.value)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .onAppear {
                                        // Exit early if next page is nil or already fetching
                                        guard let nextPageURL = nextPageURL, !isGettingNextPage else {
                                            return
                                        }
                                        fetchNextPage()
                                    }
                            }
                        }
                    }
                    if isGettingNextPage {
                        ProgressView()
                    }
                }.padding(16)
            }
        }.onAppear {
            fetchTransactions()
        }
    }

    /// Fetches transactions for the given account.
    func fetchTransactions() {
        isLoading = true
        networkManager.fetchInitialTransactions(from: account.transactionLink) { result in
            isLoading = false
            switch result {
            case .success(let nextPage):
                self.nextPageURL = nextPage
                // Noop
                break
            case .failure(let error):
                self.error = error
                print("Failed to fetch transactions: \(error.localizedDescription)")
            }
        }
    }

    func fetchNextPage() {
        guard let nextPageURL = nextPageURL else { return }
        isGettingNextPage = true
        networkManager.fetchNextPageTransactions(from: nextPageURL) { result in
            switch result {
            case .success(let nextPage):
                self.nextPageURL = nextPage
                isGettingNextPage = false
                // Noop
                break
            case .failure(let error):
                self.error = error
                print("Failed to fetch transactions: \(error.localizedDescription)")
                isGettingNextPage = false
            }
        }
    }
}
