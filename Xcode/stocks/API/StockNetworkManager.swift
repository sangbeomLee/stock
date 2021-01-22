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

// TODO: - Fetch naming 고려해보기
class StockNetworkManager {
    typealias FetchResult<T> = Result<T, Error>
    
    static let shared = StockNetworkManager(downloader: Downloader.shared)
    
    private var downloader: Downloader
    
    init(downloader: Downloader) {
        self.downloader = downloader
    }
    
    // TODO: - fetch 를 사용해서 모든 것을 다 할 수 있게 하자.
    func fetch<T: Codable>(dataType: T.Type, for symbols: [String], completion: @escaping ([(String, FetchResult<T>)]) -> Void) {
        getFetchData(for: symbols, completion: completion)
    }
    
    
    func getFetchData<T: Codable>(for symbols: [String], completion: @escaping ([(String, FetchResult<T>)]) -> Void) {
        var results = [(String, FetchResult<T>)]()
        // TODO: - 좀더 여기에 알맞는 네이밍 고려해보기
        let dispatchGroup = DispatchGroup()
        
        symbols.forEach {[weak self] symbol in
            dispatchGroup.enter()
            self?.downloadData(for: symbol) { (result: FetchResult<T>) in
                results.append((symbol, result))
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(results)
        }
    }
    
    func downloadData<T: Codable>(for symbol: String, completion: @escaping (FetchResult<T>) -> Void) {
        guard let url = Finnhub.quoteUrl(symbol) else {
            completion(FetchResult.failure(NetworkError.url))
            return
        }
        
        downloader.downloadData(from: url) { result in
            switch result {
            case .success(let data):
                if let decodedData: T = self.parseJson(for: data) {
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
    func parseJson<T: Codable>(for data: Data) -> T? {
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
