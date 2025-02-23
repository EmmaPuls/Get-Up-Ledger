import Foundation

/// NetworkManager is responsible for handling network requests related to accounts.
class NetworkManager: ObservableObject {
    /// Published property to store the list of accounts.
    @Published var accounts: [Account] = []
    @Published var accountTransactionsCache: [String: [Transaction]] = [:]
    @Published var currentTransactions: [Transaction] = []

    /// Performs a network request and decodes the response.
    /// - Parameters:
    ///   - url: The URL to fetch data from.
    ///   - completion: A closure that gets called with the result of the fetch operation.
    private func performRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        // Retrieve the API key from UserDefaults.
        guard let apiAuth = UserDefaults.standard.string(forKey: "upBankAPIKey"), !apiAuth.isEmpty else {
            print("Failure: Missing API Key")
            completion(.failure(NetworkError.missingAPIKey))
            return
        }

        let headers = [
            "Authorization": "Bearer \(apiAuth)"
        ]

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Failure: Network error or no data")
                completion(.failure(error ?? NetworkError.unknown))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Failure: HTTP error with status code \(httpResponse.statusCode)")
                completion(.failure(NetworkError.httpError(httpResponse.statusCode)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse))
                }
            } catch {
                print("Failure: Decoding error \(error)")
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        task.resume()
    }

    /// Fetches accounts from the API.
    /// - Parameter completion: A closure that gets called with the result of the fetch operation.
    func fetchAccounts(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "https://api.up.com.au/api/v1/accounts?page[size]=40") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        performRequest(url: url) { (result: Result<AccountResponse, Error>) in
            switch result {
            case .success(let accountResponse):
                self.accounts = accountResponse.data
                completion(.success(true))
            case .failure(let error):
                print("Failure in fetchAccounts: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// Fetches the transactions from a given url.
    /// - Parameters:
    ///  - url: The URL to fetch the transactions from.
    func fetchTransactions(from: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        if let cachedTransactions = accountTransactionsCache[from] {
            currentTransactions = cachedTransactions
            completion(.success(true))
            return
        }

        guard let url = URL(string: from + "?page[size]=40") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        performRequest(url: url) { (result: Result<TransactionResponse, Error>) in
            switch result {
            case .success(let transactionResponse):
                self.currentTransactions = transactionResponse.data
                self.accountTransactionsCache[from] = transactionResponse.data
                completion(.success(true))
            case .failure(let error):
                print("Failure in fetchTransactions: \(error)")
                completion(.failure(error))
            }
        }
    }
}

/// Enum representing possible network errors.
enum NetworkError: Error {
    case missingAPIKey
    case invalidURL
    case httpError(Int)
    case decodingError(Error)
    case unknown
}
