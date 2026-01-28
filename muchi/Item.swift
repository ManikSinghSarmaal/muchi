//
//  Item.swift
//  muchi
//
//  Created by Manik Singh Sarmaal on 28/01/26.
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
