//
//  StockNetworkManager.swift
//  stocks
//
//  Created by 이상범 on 2021/01/21.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

enum NetworkError: Error {
    case url
    case parseJson
}

class StockNetworkManager {
    typealias FetchResult<T> = Result<T, Error>
    
    static let shared = StockNetworkManager(downloader: Downloader.shared)
    
    private var downloader: Downloader
    
    init(downloader: Downloader) {
        self.downloader = downloader
    }
    
    func getQuotes(with symbols: [String], completion: @escaping (([FetchResult<Finnhub.Quote>]) -> Void)) {
        var results = [FetchResult<Finnhub.Quote>]()
        // TODO: - 좀더 여기에 알맞는 네이밍 고려해보기
        let dispatchGroup = DispatchGroup()
        
        symbols.forEach { symbol in
            dispatchGroup.enter()
            self.getQuote(with: symbol) { (result: FetchResult<Finnhub.Quote>) in
                results.append(result)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(results)
        }
    }
    
    func getQuote<T: Codable>(with symbol: String, completion: @escaping (FetchResult<T>) -> Void) {
        guard let url = Finnhub.quoteUrl(symbol) else {
            completion(FetchResult.failure(NetworkError.url))
            return
        }
        
        downloader.downloadData(from: url) { result in
            switch result {
            case .success(let data):
                if let decodedData: T = self.parseJson(with: data) {
                    completion(FetchResult.success(decodedData))
                } else {
                    completion(FetchResult.failure(NetworkError.parseJson))
                }
            case .failure(let error):
                completion(FetchResult.failure(error))
            }
        }
    }
}

private extension StockNetworkManager {
    func parseJson<T: Codable>(with data: Data) -> T? {
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
