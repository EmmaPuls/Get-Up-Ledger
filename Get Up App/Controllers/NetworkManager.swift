import Foundation

/// NetworkManager is responsible for handling network requests related to accounts.
class NetworkManager: ObservableObject {
    /// Published property to store the list of accounts.
    @Published var accounts: [Account] = []
    @Published var accountTransactionsCache: [String: [Transaction]] = [:]
    @Published var currentTransactions: [Transaction] = []

    /// Fetches accounts from the API.
    /// - Parameter completion: A closure that gets called with the result of the fetch operation.
    func fetchAccounts(completion: @escaping (Result<Bool, Error>) -> Void) {
        // Retrieve the API key from UserDefaults.
        guard let apiAuth = UserDefaults.standard.string(forKey: "upBankAPIKey"), !apiAuth.isEmpty else {
            print("API key is missing. Please set your API key in the app settings.")
            completion(.failure(NetworkError.missingAPIKey))
            return
        }

        let headers = [
            "Authorization": "Bearer \(apiAuth)"
        ]

        // Construct the URL with query parameters.
        var urlComponents = URLComponents(string: "https://api.up.com.au/api/v1/accounts")
        urlComponents?.queryItems = [
            URLQueryItem(name: "page[size]", value: "40")
        ]

        guard let url = urlComponents?.url else {
            print("Invalid URL.")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        let session = URLSession(configuration: config)

        // Perform the network request.
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error from the API: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error ?? NetworkError.unknown))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("HTTP Error: \(httpResponse.statusCode)")
                completion(.failure(NetworkError.httpError(httpResponse.statusCode)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let accountResponse = try decoder.decode(AccountResponse.self, from: data)

                DispatchQueue.main.async {
                    self.accounts = accountResponse.data
                    completion(.success(true))
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        task.resume()
    }

    /// Fetches the transactions from a given url.
    /// - Parameters:
    ///  - url: The URL to fetch the transactions from.
    func fetchTransactions(from: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Check if this URL has recently been fetched
        if let cachedTransactions = accountTransactionsCache[from] {
            currentTransactions = cachedTransactions
            completion(.success(true))
            return
        }

        // Retrieve the API key from UserDefaults.
        guard let apiAuth = UserDefaults.standard.string(forKey: "upBankAPIKey"), !apiAuth.isEmpty else {
            print("API key is missing. Please set your API key in the app settings.")
            completion(.failure(NetworkError.missingAPIKey))
            return
        }

        let headers = [
            "Authorization": "Bearer \(apiAuth)"
        ]
        
        var urlComponents = URLComponents(string: from)
        urlComponents?.queryItems = [URLQueryItem(name: "page[size]", value: "40")]

        guard let url = urlComponents?.url else {
            print("Invalid URL.")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        let session = URLSession(configuration: config)

        // Perform the network request.
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error from the API: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error ?? NetworkError.unknown))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("HTTP Error: \(httpResponse.statusCode)")
                completion(.failure(NetworkError.httpError(httpResponse.statusCode)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let transactionResponse = try decoder.decode(TransactionResponse.self, from: data)

                DispatchQueue.main.async {
                    self.currentTransactions = transactionResponse.data
                    self.accountTransactionsCache[from] = transactionResponse.data
                    completion(.success(true))
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                // Log out the whole error for debugging purposes
                print(error)
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        task.resume()
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
