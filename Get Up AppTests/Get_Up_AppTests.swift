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
