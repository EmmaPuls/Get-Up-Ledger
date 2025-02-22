//
//  Item.swift
//  Get Up App
//
//  Created by Emma Puls on 22/2/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
