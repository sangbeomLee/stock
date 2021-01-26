//
//  Sort.swift
//  stocks
//
//  Created by 이상범 on 2021/01/26.
//  Copyright © 2021 dk. All rights reserved.
//

import Foundation

extension StockListViewController {
    enum Sort: Int {
        case change
        case percent
        case price
        case symbol
        
        var next: Sort {
            Sort(rawValue: (rawValue + 1) % 4) ?? self
        }
        
        var title: String {
            switch self {
            case .symbol:
                return "Alphabetical"
            case .percent:
                return "Percent Change"
            case .price:
                return "Current Price"
            case .change:
                return "Price Change"
            }
        }
    }
}
