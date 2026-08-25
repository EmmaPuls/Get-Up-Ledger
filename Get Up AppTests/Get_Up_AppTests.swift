//
//  Get_Up_AppTests.swift
//  Get Up AppTests
//
//  Created by Emma Puls on 22/2/2025.
//

import Foundation
import Testing
@testable import Get_Up_Ledger

struct Get_Up_AppTests {

    // MARK: - GUA-5: transaction relationships

    @Test func transactionDecodesAllRelationshipTypes() throws {
        let json = """
        {
          "id": "transaction-1",
          "type": "transactions",
          "attributes": {
            "status": "SETTLED",
            "rawText": null,
            "description": "Lunch",
            "message": null,
            "isCategorizable": true,
            "holdInfo": null,
            "roundUp": null,
            "cashBack": null,
            "amount": { "currencyCode": "AUD", "value": "-12.50", "valueInBaseUnits": -1250 },
            "foreignAmount": null,
            "cardPurchaseMethod": null,
            "settledAt": "2025-01-01T00:00:00+10:00",
            "createdAt": "2025-01-01T00:00:00+10:00",
            "transactionType": "Purchase",
            "note": null,
            "performingCustomer": null,
            "deepLinkURL": "up://transaction/1"
          },
          "relationships": {
            "account": {
              "data": { "type": "accounts", "id": "account-1" },
              "links": { "related": "https://api.up.com.au/api/v1/accounts/account-1" }
            },
            "transferAccount": {
              "data": { "type": "accounts", "id": "account-2" },
              "links": { "related": "https://api.up.com.au/api/v1/accounts/account-2" }
            },
            "category": {
              "data": { "type": "categories", "id": "eating-out" },
              "links": { "self": "https://api.up.com.au/api/v1/transactions/transaction-1/relationships/category", "related": "https://api.up.com.au/api/v1/categories/eating-out" }
            },
            "parentCategory": {
              "data": { "type": "categories", "id": "good-life" },
              "links": { "related": "https://api.up.com.au/api/v1/categories/good-life" }
            },
            "tags": {
              "data": [{ "type": "tags", "id": "Lunch" }],
              "links": { "self": "https://api.up.com.au/api/v1/transactions/transaction-1/relationships/tags" }
            },
            "attachment": {
              "data": { "type": "attachments", "id": "attachment-1" },
              "links": { "related": "https://api.up.com.au/api/v1/attachments/attachment-1" }
            }
          }
        }
        """

        let transaction = try JSONDecoder().decode(Transaction.self, from: Data(json.utf8))

        #expect(transaction.relationships.account.data?.id == "account-1")
        #expect(transaction.relationships.transferAccount.data?.id == "account-2")
        #expect(transaction.relationships.category.data?.id == "eating-out")
        #expect(transaction.relationships.category.links?.selfURL?.hasSuffix("/relationships/category") == true)
        #expect(transaction.relationships.parentCategory.data?.id == "good-life")
        #expect(transaction.relationships.tags.data.map(\.id) == ["Lunch"])
        #expect(transaction.relationships.attachment.data?.id == "attachment-1")
    }

    private func decodeAttributes(displayName: String, accountType: String) throws -> AccountAttributes {
        let json = """
        {
          "displayName": "\(displayName)",
          "accountType": "\(accountType)",
          "ownershipType": "INDIVIDUAL",
          "balance": {
            "currencyCode": "AUD",
            "value": "0.00",
            "valueInBaseUnits": 0
          },
          "createdAt": "2025-01-01T00:00:00+10:00"
        }
        """
        return try JSONDecoder().decode(AccountAttributes.self, from: Data(json.utf8))
    }

    // MARK: - GUA-9: emoji fallback for transactional accounts

    @Test func transactionalAccountWithoutEmojiFallsBackToCreditCard() throws {
        let attrs = try decodeAttributes(displayName: "Spending", accountType: "TRANSACTIONAL")

        #expect(attrs.emoji == "💳")
        #expect(attrs.modifiedDisplayName == "Spending")
    }

    @Test func transactionalAccountWithUserEmojiKeepsUserEmoji() throws {
        let attrs = try decodeAttributes(displayName: "🍕 Pizza Fund", accountType: "TRANSACTIONAL")

        #expect(attrs.emoji == "🍕")
        #expect(attrs.modifiedDisplayName == "Pizza Fund")
    }

    @Test func saverAccountWithoutEmojiHasNilEmoji() throws {
        // Demonstrates current behaviour for non-transactional accounts: no fallback is applied,
        // so the emoji column will still be empty for a saver that hasn't been given an emoji.
        let attrs = try decodeAttributes(displayName: "Holiday", accountType: "SAVER")

        #expect(attrs.emoji == nil)
        #expect(attrs.modifiedDisplayName == "Holiday")
    }

    @Test func saverAccountWithUserEmojiKeepsUserEmoji() throws {
        let attrs = try decodeAttributes(displayName: "💰 Savings", accountType: "SAVER")

        #expect(attrs.emoji == "💰")
        #expect(attrs.modifiedDisplayName == "Savings")
    }

    @Test func saverAccountWithEmojiAndTrailingWhitespaceTrimsBothEnds() throws {
        let attrs = try decodeAttributes(displayName: "🐶 Dog ", accountType: "SAVER")

        #expect(attrs.emoji == "🐶")
        #expect(attrs.modifiedDisplayName == "Dog")
    }

    @Test func saverAccountWithEmojiAndNoSpaceLeavesNameIntact() throws {
        let attrs = try decodeAttributes(displayName: "🐶Dog", accountType: "SAVER")

        #expect(attrs.emoji == "🐶")
        #expect(attrs.modifiedDisplayName == "Dog")
    }
}
