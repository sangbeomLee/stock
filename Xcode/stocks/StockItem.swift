//
//  Item.swift
//  stocks
//
//  Created by Daniel on 5/28/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct StockItem: Codable {
    var symbol: String?
    var quote: QueteModel?
}

extension StockItem: Equatable {
    static func ==(lhs: StockItem, rhs: StockItem) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}
