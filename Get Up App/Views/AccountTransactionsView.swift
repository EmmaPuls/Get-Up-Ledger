import SwiftUI

/// A view that displays the transactions of an account.
struct AccountTransactionsView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var networkManager = NetworkManager()
    @State private var isLoading = false
    @State private var error: Error?
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
                            }
                        }
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
        networkManager.fetchTransactions(from: account.transactionLink) { result in
            isLoading = false
            switch result {
            case .success:
                // Noop
                break
            case .failure(let error):
                self.error = error
                print("Failed to fetch transactions: \(error.localizedDescription)")
            }
        }
    }
}
