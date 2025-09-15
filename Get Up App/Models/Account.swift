import SwiftData

/// Represents an account model with attributes, relationships, and links.
@Model
final class Account: Codable, Identifiable, Equatable {
    var type: String
    var id: String
    var attributes: AccountAttributes
    var transactionLink: String

    enum CodingKeys: String, CodingKey {
        case type
        case id
        case attributes
        case relationships
        case transactionLink
    }

    /// Initializes an Account instance from a decoder.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        id = try container.decode(String.self, forKey: .id)
        attributes = try container.decode(AccountAttributes.self, forKey: .attributes)
        let relationships = try container.decode(RelationshipResponse.self, forKey: .relationships)
        transactionLink = relationships.transactions.links.related!
    }

    /// Encodes the Account instance to an encoder.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(attributes, forKey: .attributes)
    }

    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Represents the attributes of an account.
struct AccountAttributes: Codable {
    var displayName: String
    var modifiedDisplayName: String?
    var accountType: String
    var ownershipType: String
    var balance: Balance
    var createdAt: String
    var emoji: String?

    enum CodingKeys: String, CodingKey {
        case displayName
        case modifiedDisplayName
        case accountType
        case ownershipType
        case balance
        case createdAt
        case emoji
    }

    /// Initializes an AccountAttributes instance from a decoder.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try container.decode(String.self, forKey: .displayName)
        modifiedDisplayName = try container.decodeIfPresent(String.self, forKey: .modifiedDisplayName)
        accountType = try container.decode(String.self, forKey: .accountType)
        ownershipType = try container.decode(String.self, forKey: .ownershipType)
        balance = try container.decode(Balance.self, forKey: .balance)
        createdAt = try container.decode(String.self, forKey: .createdAt)

        // If the first character in displayName is an emoji, remove it and add it to the emoji property
        if let firstCharacter = displayName.first, firstCharacter.isEmoji {
            emoji = String(firstCharacter)
            modifiedDisplayName = String(displayName.dropFirst())
        } else {
            emoji = nil
            modifiedDisplayName = displayName
        }
    }

    /// Encodes the AccountAttributes instance to an encoder.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(accountType, forKey: .accountType)
        try container.encode(ownershipType, forKey: .ownershipType)
        try container.encode(balance, forKey: .balance)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(modifiedDisplayName, forKey: .modifiedDisplayName)
        try container.encode(emoji, forKey: .emoji)
    }
}

/// Represents a response containing a list of accounts.
struct AccountResponse: Codable {
    var data: [Account]
    var links: LinksResponse
}

/// Represents the relationships of an account, specifically transactions.
struct RelationshipResponse: Codable {
    var transactions: AccountTransactionLinkResponse

    enum CodingKeys: String, CodingKey {
        case transactions = "transactions"
    }

    /// Initializes a RelationshipResponse instance from a decoder.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transactions = try container.decode(AccountTransactionLinkResponse.self, forKey: .transactions)
    }

    /// Encodes the RelationshipResponse instance to an encoder.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transactions, forKey: .transactions)
    }
}

/// Represents a response containing transaction links.
struct AccountTransactionLinkResponse: Codable {
    var links: AccountLinksResponse

    enum CodingKeys: String, CodingKey {
        case links = "links"
    }

    /// Initializes a TransactionResponse instance from a decoder.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        links = try container.decode(AccountLinksResponse.self, forKey: .links)
    }

    /// Encodes the TransactionResponse instance to an encoder.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(links, forKey: .links)
    }
}

/// Represents the links associated with an account or transaction.
struct AccountLinksResponse: Codable {
    var related: String?
    var selfString: String?

    enum CodingKeys: String, CodingKey {
        case related = "related"
        case selfString = "self"
    }

    /// Initializes a LinksResponse instance from a decoder.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        related = try container.decodeIfPresent(String.self, forKey: .related)
        selfString = try container.decodeIfPresent(String.self, forKey: .selfString)
    }

    /// Encodes the LinksResponse instance to an encoder.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(related, forKey: .related)
        try container.encode(selfString, forKey: .selfString)
    }
}
