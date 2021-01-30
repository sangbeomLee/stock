//
//  Finnhub.swift
//  stocks
//
//  Created by Daniel on 5/27/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

// 이 부분은 딱 Network 관련 일만 했으면 좋겠다.
// StockNetworkModel << 이라고 바꾸자.
// StockModel << 사용하는 모델이름
// URL 은 누가 가지고있어야 하는가? -> NetworkManager 에서 가지고 있는게 맞는듯하다.
struct StockNetworkModel {
    struct Executive: Codable {
        var age: Int?
        var compensation: Int?
        var currency: String
        var name: String
        var position: String?
        var since: String?
    }

    struct ExecutiveResponse: Codable {
        var executive: [Executive]
    }

    struct Dividend: Codable {
        var date: String
        var amount: Double
        var payDate: String
        var currency: String
    }

    struct News: Codable {
        var datetime: Int
        var headline: String
        // TODO: display        var image: URL?
        var source: String
        var summary: String
        var url: URL
    }

    struct Profile: Codable {
        var country: String
        var currency: String
        var exchange: String
        var finnhubIndustry: String
        var ipo: String
        var logo: String?
        var marketCapitalization: Double
        var name: String
        var shareOutstanding: Double
        var weburl: URL
    }

    struct Quote: Codable {
        var c: Double  // current
        var pc: Double // previous close
    }

    struct Search: Codable {
        var result: [Result]
        
        struct Result: Codable {
            var description: String
            var symbol: String
        }
    }
}

// MARK: - static url func
extension StockNetworkModel {
    static func dividendUrl(_ symbol: String?) -> URL? {
        return url(path: Endpoint.dividend.path, symbol: symbol, numberOfDays: 365)
    }

    static func executiveUrl(_ symbol: String) -> URL? {
        return url(path: Endpoint.executive.path, symbol: symbol)
    }

    static func newsUrl(_ symbol: String?) -> URL? {
        return url(path: Endpoint.companyNews.path, symbol: symbol, numberOfDays: 14)
    }

    static func profile2Url(_ symbol: String) -> URL? {
        return url(path: Endpoint.profile2.path, symbol: symbol)
    }

    static func quoteUrl(_ symbol: String) -> URL? {
        return url(path: Endpoint.quote.path, symbol: symbol)
    }

    static func searchUrl(from text: String) -> URL? {
        return url(path: Endpoint.search.path, text: text)
    }
}

extension StockNetworkModel {
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return dateFormatter
    }

}

extension StockNetworkModel.Quote {
    var quoteModel: QueteModel {
        return QueteModel(price: c, change: c - pc)
    }
}

// TODO: - Detail 쪽은 다시 설계하는것이 좋을 듯 하다.
private extension StockNetworkModel {

    static let apiKey = APIKey.key

    static let host = "finnhub.io"
    static let baseUrl = "/api/v1"

    enum Endpoint: String {
        case companyNews
        case search
        case dividend, executive, profile2, quote

        var path: String {
            switch self {
            case .companyNews:
                return "\(baseUrl)/company-news"
            case .quote:
                return "\(baseUrl)/\(self.rawValue)"
            case .search:
                return "\(baseUrl)/\(self.rawValue)"
            case .dividend, .executive, .profile2 :
                return "\(baseUrl)/stock/\(self.rawValue)"
            }
        }
    }

    // TODO: - 뭐하는 녀석인지..?
    static var baseUrlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host

        return components
    }

    // TODO: - 뭐하는 녀석인지..?
    static var tokenQueryItem: URLQueryItem {
        let queryItem = URLQueryItem(name: "token", value: apiKey)
        return queryItem
    }

    static func url(path: String, queryItems: [URLQueryItem]) -> URL? {
        var components = baseUrlComponents
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
    
    // TODO: - naming
    static func url(path: String, symbol: String?, numberOfDays: TimeInterval? = nil) -> URL?{
        guard let symbol = symbol else { return nil }

        let s = URLQueryItem(name: "symbol", value: symbol)

        guard let numberOfDays = numberOfDays else {
            let queryItems = [tokenQueryItem, s]

            return url(path: path, queryItems: queryItems)
        }

        let fromDate = Date().addingTimeInterval(-numberOfDays * 24 * 60 * 60)
        let from = dateFormatter.string(from: fromDate)
        let fromQi = URLQueryItem(name: "from", value: from)

        let to = dateFormatter.string(from: Date())
        let toQi = URLQueryItem(name: "to", value: to)

        let queryItems = [ tokenQueryItem, s, fromQi, toQi ]
        
        return url(path: path, queryItems: queryItems)
    }
    
    static func url(path: String, text: String) -> URL? {
        var components = baseUrlComponents
        components.path = Endpoint.search.path
        
        let limitQuuery = URLQueryItem(name: "q", value: text)
        let queryItems = [limitQuuery, tokenQueryItem]

        return url(path: path, queryItems: queryItems)
    }
}


