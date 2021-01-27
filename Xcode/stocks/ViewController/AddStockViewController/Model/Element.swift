//
//  Element.swift
//  stocks
//
//  Created by 이상범 on 2021/01/26.
//  Copyright © 2021 dk. All rights reserved.
//

import Foundation

extension AddStockViewController {
    /// AddStockViewController 를 구성하는 Stock Element 입니다.
    struct Element {
        let symbol: String
        let description: String?
    }
}

// TODO: - 이 부분 바꾸자
extension Array {
    mutating func loadPopularStocks() where Element == AddStockViewController.Element {
        let popularSymbols: [String] =
            [
                "AAPL",
                "TSLA",
                "DIS",
                "MSFT",
                "SNAP",
                "UBER",
                "TWTR",
                "AMD",
                "FB",
                "LK",
                "AMZN",
                "SHOP"
        ]
        // TODO: - SearchResult 를 가져와야한다.
        popularSymbols.forEach { str in
            self.append(AddStockViewController.Element(symbol: str, description: nil))
        }
    }
}
