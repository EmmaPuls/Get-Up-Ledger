import SwiftData

@Model
final class Account: Codable, Identifiable {
    var type: String
    var id: String
    var attributes: AccountAttributes
    
    enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        id = try container.decode(String.self, forKey: .id)
        attributes = try container.decode(AccountAttributes.self, forKey: .attributes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(attributes, forKey: .attributes)
    }
}

struct AccountAttributes: Codable {
    var displayName: String
    var accountType: String
    var ownershipType: String
    var balance: Balance
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case displayName
        case accountType
        case ownershipType
        case balance
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try container.decode(String.self, forKey: .displayName)
        accountType = try container.decode(String.self, forKey: .accountType)
        ownershipType = try container.decode(String.self, forKey: .ownershipType)
        balance = try container.decode(Balance.self, forKey: .balance)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(accountType, forKey: .accountType)
        try container.encode(ownershipType, forKey: .ownershipType)
        try container.encode(balance, forKey: .balance)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

struct AccountResponse: Codable {
    var data: [Account]
}
