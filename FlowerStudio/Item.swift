//
//  Item.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
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
