//
//  NetworkManager.swift
//  Get Up App
//
//  Created by Emma Puls on 22/2/2025.
//

import Foundation

class NetworkManager: ObservableObject {
    @Published var accounts: [Account] = []

    func fetchAccounts(completion: @escaping (Bool) -> Void) {
        print("0")
        let apiAuth = UserDefaults.standard.string(forKey: "upBankAPIKey") ?? ""
        let pageSize = 10
        
        if(apiAuth.isEmpty){
            // exit with error
            // Todo: Provide user with feedback on how to resolve this
            completion(false)
            return
        }
        
        
        let headers = [
            "Authorization": "Bearer \(apiAuth)"
        ]
        
        // ...existing code...
        guard let url = URL(string: "https://api.up.com.au/api/v1/accounts") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        print("request")
        print(request)
        print("requestHeaders")
        print(request.allHTTPHeaderFields ?? [:])
        let task = URLSession.shared.dataTask(with: request) { data, response, errors in
            guard let data = data, errors == nil else {
                print("error from the API")
                completion(false)
                return
            }

            do {
                let decoder = JSONDecoder()
                print("data")
                if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                   print(JSONString)
                }
                print()
                let accountResponse = try decoder.decode(AccountResponse.self, from: data)
                print("accountResponse")
                print(accountResponse)
                DispatchQueue.main.async {
                    self.accounts = accountResponse.data
                    completion(true)
                }
            } catch (let context) {
                print("error decoding")
                print(context)
                completion(false)
            }
        }
        task.resume()
    }
}
