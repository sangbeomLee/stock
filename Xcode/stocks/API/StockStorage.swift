//
//  Storage.swift
//  stocks
//
//  Created by 이상범 on 2021/01/21.
//  Copyright © 2021 dk. All rights reserved.
//

import Foundation

class StockStorage {
    static var shared = StockStorage()
    
    var symbols: [String] {
        return stockItems.compactMap { $0.symbol }
    }
    
    var isEmpty: Bool {
        stockItems.count == 0
    }

    func loadStockItems() -> [StockItem] {
        return stockItems
    }

    func saveStockItems(_ items: [StockItem]) {
        stockItems = items
    }

    private var stockItems: [StockItem] = UserDefaultsConfig.list {
        didSet {
            UserDefaultsConfig.list = stockItems
        }
    }
}

// TODO: - 더 알아볼 것
private struct UserDefaultsConfig {
    @UserDefault("stockItems", defaultValue: [])
    fileprivate static var list: [StockItem]
}
