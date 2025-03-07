//
//  Item.swift
//  ntfy.app
//
//  Created by Pablo Espinel on 7/3/25.
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
