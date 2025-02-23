import Foundation

struct Balance: Codable {
    var currencyCode: String
    var value: String
    var valueInBaseUnits: Int

    enum CodingKeys: String, CodingKey {
        case currencyCode
        case value
        case valueInBaseUnits
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currencyCode = try container.decode(String.self, forKey: .currencyCode)
        value = try container.decode(String.self, forKey: .value)
        valueInBaseUnits = try container.decode(Int.self, forKey: .valueInBaseUnits)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(value, forKey: .value)
        try container.encode(valueInBaseUnits, forKey: .valueInBaseUnits)
    }
    
    // TODO: Let users define the number format
    func toString() -> String {
        // Format the valueInBaseUnits to a string format for dollars (including dollars and decimal points, assume the last two digits are the decimal points
        let dollars = valueInBaseUnits / 100
        let cents = valueInBaseUnits % 100
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedDollars = formatter.string(from: NSNumber(value: dollars)) ?? "\(dollars)"
        let formattedCents = cents < 10 ? "0\(cents)" : "\(cents)"
        return "$\(formattedDollars).\(formattedCents) \(currencyCode)"
    }
}

struct LocalAndForeignBalance: Codable {
    var amount: Balance
    var foreignAmount: Balance?
}
