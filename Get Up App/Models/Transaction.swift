//
//  Transaction.swift
//  Get Up App
//
//  Created by Emma Puls on 23/2/2025.
//

// TODO: Add Tranaction relationships field
final class Transaction: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: TransactionAttributes

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case attributes
        case relationships
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        attributes = try container.decode(TransactionAttributes.self, forKey: .attributes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(attributes, forKey: .attributes)
    }
}

enum TransactionStatus: String, Codable {
    case held = "HELD"
    case settled = "SETTLED"
}

struct TransactionAttributes: Codable {
    let status: TransactionStatus
    let rawText: String?
    let description: String
    let message: String?
    let isCategorizable: Bool
    let holdInfo: LocalAndForeignBalance?
    let roundUp: RoundUp?
    let cashBack: CashBack?
    let amount: Balance
    let foreignAmount: Balance?
    let cardPurchaseMethod: CardPurchaseMethod?
    let settledAt: String?
    let createdAt: String
    let transactionType: String?
    let note: Note?
    let performingCustomer: Customer?
    let deepLinkURL: String?

    enum CodingKeys: String, CodingKey {
        case status
        case rawText
        case description
        case message
        case isCategorizable
        case holdInfo
        case roundUp
        case cashBack
        case amount
        case foreignAmount
        case cardPurchaseMethod
        case settledAt
        case createdAt
        case transactionType
        case note
        case performingCustomer
        case deepLinkURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(TransactionStatus.self, forKey: .status)
        rawText = try container.decodeIfPresent(String.self, forKey: .rawText)
        description = try container.decode(String.self, forKey: .description)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        isCategorizable = try container.decode(Bool.self, forKey: .isCategorizable)
        holdInfo = try container.decodeIfPresent(LocalAndForeignBalance.self, forKey: .holdInfo)
        roundUp = try container.decodeIfPresent(RoundUp.self, forKey: .roundUp)
        cashBack = try container.decodeIfPresent(CashBack.self, forKey: .cashBack)
        amount = try container.decode(Balance.self, forKey: .amount)
        foreignAmount = try container.decodeIfPresent(Balance.self, forKey: .foreignAmount)
        cardPurchaseMethod = try container.decodeIfPresent(CardPurchaseMethod.self, forKey: .cardPurchaseMethod)
        settledAt = try container.decodeIfPresent(String.self, forKey: .settledAt)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        transactionType = try container.decodeIfPresent(String.self, forKey: .transactionType)
        note = try container.decodeIfPresent(Note.self, forKey: .note)
        performingCustomer = try container.decodeIfPresent(Customer.self, forKey: .performingCustomer)
        deepLinkURL = try container.decodeIfPresent(String.self, forKey: .deepLinkURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        try container.encode(rawText, forKey: .rawText)
        try container.encode(description, forKey: .description)
        try container.encode(message, forKey: .message)
        try container.encode(isCategorizable, forKey: .isCategorizable)
        try container.encode(holdInfo, forKey: .holdInfo)
        try container.encode(roundUp, forKey: .roundUp)
        try container.encode(cashBack, forKey: .cashBack)
        try container.encode(amount, forKey: .amount)
        try container.encode(foreignAmount, forKey: .foreignAmount)
        try container.encode(cardPurchaseMethod, forKey: .cardPurchaseMethod)
        try container.encode(settledAt, forKey: .settledAt)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(transactionType, forKey: .transactionType)
        try container.encode(note, forKey: .note)
        try container.encode(performingCustomer, forKey: .performingCustomer)
        try container.encode(deepLinkURL, forKey: .deepLinkURL)
    }
}

struct RoundUp: Codable {
    let amount:  Balance
    let boostPortion: Balance?
}

struct CashBack: Codable {
    let amount: Balance
    let description: String
}

struct CardPurchaseMethod: Codable {
    let cardNumberSuffix: String?
    let method: String
}

struct Note: Codable {
    let text: String
}

struct TransactionResponse: Codable {
    let data: [Transaction]
}
