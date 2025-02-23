import SwiftUI

/// A reusable view for displaying error messages.
struct NetworkErrorView: View {
    let error: Error
    var errorString: String

    init(error: Error) {
        self.error = error
        switch error {
        case NetworkError.decodingError(let decodingError):
            self.errorString =
                "There was an error decoding the response from the server: \(decodingError.localizedDescription)"
        case NetworkError.httpError(let statusCode):
            if statusCode == 401 {
                self.errorString =
                    "The server returned a 401, check your API key is up to date in Settings."
            } else {
                self.errorString = "The server returned an error with status code \(statusCode)."
            }
        case NetworkError.invalidURL:
            self.errorString = "The URL used to fetch data was invalid."
        case NetworkError.missingAPIKey:
            self.errorString =
                "You must provide a valid API key to access this endpoint, go to Settings to add your API key"
        default:
            self.errorString = error.localizedDescription
        }

        print("Logging out the errorString: \(errorString)")
    }

    var body: some View {
        VStack {
            Text("An error occurred").bold().padding(.vertical)
                .accessibilityHeading(AccessibilityHeadingLevel.h1)
            Text(errorString)
        }
    }
}
