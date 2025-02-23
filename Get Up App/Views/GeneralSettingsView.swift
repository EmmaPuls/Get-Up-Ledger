// Create a MacOS SwiftUI View of the General Settings, the two settings are:
// - A select box to choose the bank API to use (the only option is UpBank for now)
// - A text field to enter the Up Bank API key (this should be stored for API queries, but should be secure)

import SwiftUI

struct GeneralSettings: View {
    @AppStorage("bankAPI") private var bankAPI: String = "Up"
    @AppStorage("upBankAPIKey") private var upBankAPIKey: String = ""

    var body: some View {
        Form {
            Picker("Bank API", selection: $bankAPI) {
                Text("Up Bank").tag("Up")
            }.pickerStyle(.menu)

            SecureField("API Key", text: $upBankAPIKey).textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}
