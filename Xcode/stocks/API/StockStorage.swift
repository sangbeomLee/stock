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

    var dataSource: [Section] {
        var sections: [Section] = []

        let section = Section(items: stockItems)
        sections.append(section)

        return sections
    }

    func loadStockItems() -> [StockItem] {
        return stockItems
    }

    func saveStockItems(_ items: [StockItem]) {
        self.stockItems = items
    }

    private var stockItems: [StockItem] = UserDefaultsConfig.list {
        didSet {
            UserDefaultsConfig.list = stockItems
        }
    }
}

// TODO: - 이 부분 Section 은 여기에 있으면 안될듯 하다.
struct Section {
    var header: String?
    var items: [StockItem]?
}

// TODO: - 더 알아볼 것
private struct UserDefaultsConfig {
    @UserDefault("stockItems", defaultValue: [])
    fileprivate static var list: [StockItem]
}
