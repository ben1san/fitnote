//
//  Item.swift
//  fitnote
//
//  Created by Hiroyuki Kubo on 2026/06/18.
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
