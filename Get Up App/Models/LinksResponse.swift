//
//  LinksResponse.swift
//  Get Up App
//
//  Created by Emma Puls on 23/2/2025.
//


/// Struct representing the links response.
struct LinksResponse: Codable {
    var prev: String?
    var next: String?

    enum CodingKeys: String, CodingKey {
        case prev
        case next
    }
}
