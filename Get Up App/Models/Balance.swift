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
}
