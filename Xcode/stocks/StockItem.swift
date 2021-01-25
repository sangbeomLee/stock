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
    var quoteModel: QueteModel?
}

extension StockItem: Equatable {
    static func ==(lhs: StockItem, rhs: StockItem) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}

extension StockItem {
    var attributedValue: NSAttributedString? {
        return quoteModel?.value
    }

    var changeAttributedValue: NSAttributedString? {
        return quoteModel?.changeValue
    }

    var percentAttributedValue: NSAttributedString? {
        return quoteModel?.percentValue
    }

    var priceAttributedValue: NSAttributedString? {
        return quoteModel?.priceAttributedValue
    }
}
