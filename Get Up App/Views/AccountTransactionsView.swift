import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// A view that displays the transactions of an account.
struct AccountTransactionsView: View {
  @Environment(\.modelContext) private var modelContext

  @StateObject private var networkManager = NetworkManager()
  @State private var isLoading = false
  @State private var isGettingNextPage = false
  @State private var error: Error?
  @State private var nextPageURL: String?
  @State private var showSavePanel = false
  @State private var savePath: URL?
  let account: Account

  var body: some View {
    VStack {
      if isLoading {
        LoadingView()
      } else if let error = error {
        NetworkErrorView(error: error)
      } else {
        transactionListView
      }
      Button(action: {
        showSavePanel = true
      }) {
        Text("Download All Transactions as CSV")
      }
      .padding()
      .fileExporter(
        isPresented: $showSavePanel,
        document: CSVDocument(transactions: networkManager.currentTransactions),
        contentType: .commaSeparatedText, defaultFilename: "transactions"
      ) { result in
        switch result {
        case .success(let url):
          print("CSV file saved at: \(url)")
          savePath = url
        case .failure(let error):
          print("Failed to save CSV file: \(error.localizedDescription)")
        }
      }
    }
    .onAppear {
      fetchTransactions()
    }
    .alert(isPresented: .constant(savePath != nil)) {
      Alert(
        title: Text("File Saved"), message: Text("CSV file saved at: \(savePath?.path ?? "")"),
        dismissButton: .default(Text("OK")))
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

  private var transactionListView: some View {
    List {
      if !networkManager.currentTransactions.isEmpty {
        ForEach(networkManager.currentTransactions, id: \.id) { transaction in
          transactionRowView(for: transaction)
        }
      }
    }
    .padding(16)
  }

  private func transactionRowView(for transaction: Transaction) -> some View {
    HStack {
      Text(transaction.attributes.description)
        .frame(maxWidth: .infinity, alignment: .leading)
      Text(transaction.attributes.performingCustomer?.displayName ?? "")
      Text(transaction.attributes.amount.value)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .onAppear {
          handleOnAppear(for: transaction)
        }
    }
  }

  private func handleOnAppear(for transaction: Transaction) {
    // If the last transaction is visible, fetch the next page
    if networkManager.currentTransactions.last == transaction {
      fetchNextPage()
    }
  }
}

struct CSVDocument: FileDocument {
  static var readableContentTypes: [UTType] { [.commaSeparatedText] }

  var transactions: [Transaction]

  init(transactions: [Transaction]) {
    self.transactions = transactions
  }

  init(configuration: ReadConfiguration) throws {
    self.transactions = []
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    let csvText = generateCSV(from: transactions)
    guard let data = csvText.data(using: .utf8) else {
      throw NSError(
        domain: "CSVDocument", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Failed to encode CSV text to UTF-8 data"])
    }
    return FileWrapper(regularFileWithContents: data)
  }

  private func generateCSV(from transactions: [Transaction]) -> String {
    var csvText =
      "ID,Description,Customer,Amount,Date,Status,RawText,Message,IsCategorizable,HoldInfo,RoundUp,CashBack,ForeignAmount,CardPurchaseMethod,SettledAt,TransactionType,Note,DeepLinkURL\n"

    for transaction in transactions {
      let id = escapeForCSV(transaction.id)
      let description = escapeForCSV(transaction.attributes.description)
      let customer = escapeForCSV(transaction.attributes.performingCustomer?.displayName ?? "")
      let amount = escapeForCSV(transaction.attributes.amount.value)
      let date = escapeForCSV(transaction.attributes.createdAt)
      let status = escapeForCSV(transaction.attributes.status.rawValue)
      let rawText = escapeForCSV(transaction.attributes.rawText ?? "")
      let message = escapeForCSV(transaction.attributes.message ?? "")
      let isCategorizable = escapeForCSV(String(transaction.attributes.isCategorizable))
      let holdInfo = escapeForCSV(transaction.attributes.holdInfo?.amount.value ?? "")
      let roundUp = escapeForCSV(transaction.attributes.roundUp?.amount.value ?? "")
      let cashBack = escapeForCSV(transaction.attributes.cashBack?.description ?? "")
      let foreignAmount = escapeForCSV(transaction.attributes.foreignAmount?.value ?? "")
      let cardPurchaseMethod = escapeForCSV(transaction.attributes.cardPurchaseMethod?.method ?? "")
      let settledAt = escapeForCSV(transaction.attributes.settledAt ?? "")
      let transactionType = escapeForCSV(transaction.attributes.transactionType ?? "")
      let note = escapeForCSV(transaction.attributes.note?.text ?? "")
      let deepLinkURL = escapeForCSV(transaction.attributes.deepLinkURL ?? "")
      let newLine =
        "\(id),\(description),\(customer),\(amount),\(date),\(status),\(rawText),\(message),\(isCategorizable),\(holdInfo),\(roundUp),\(cashBack),\(foreignAmount),\(cardPurchaseMethod),\(settledAt),\(transactionType),\(note),\(deepLinkURL)\n"
      csvText.append(newLine)
    }
    return csvText
  }

  /// Escapes a given string for use in a CSV file.
  ///
  /// This function ensures that the input string is properly formatted for inclusion in a CSV file.
  /// It typically handles escaping special characters such as quotes and commas, and may wrap the
  /// string in quotes if necessary.
  ///
  /// - Parameter value: The string to be escaped for CSV formatting.
  /// - Returns: A properly escaped string suitable for use in a CSV file.
  private func escapeForCSV(_ value: String) -> String {
    var escaped = value
    if escaped.contains("\"") {
      escaped = escaped.replacingOccurrences(of: "\"", with: "\"\"")
    }
    if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
      escaped = "\"\(escaped)\""
    }
    return escaped
  }
}
