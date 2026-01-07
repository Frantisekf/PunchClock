//
//  Item.swift
//  PunchClock
//
//  Created by Frantisek Farkas on 07.01.2026.
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
