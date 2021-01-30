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
        getFetchedData(for: symbols, completion: completion)
    }
    
    func fetchDetailData(for symbol: String, completion: @escaping (FetchResult<DetailStockModel>) -> Void) {
        getFetchedDetailResult(for: symbol, completion: completion)
    }
    
    // TODO: - SearchResult 실행하기
    func fetchSearchResults(_ text: String, completion: @escaping (FetchResult<StockNetworkModel.Search>) -> Void) {
        let url = StockNetworkModel.searchUrl(from: text)
        
        downloadData(from: url) { (results: FetchResult<StockNetworkModel.Search>) in
            switch results {
            case .success(let searchResult):
                // TODO: - 이름 바꾸고 q= 에 해당하는 것 인자로 넣어주기.
                // 1. hasPrefix
                // 2. 정렬
                // 3. 20개만
                // CHECK: - 이 부분 경험 정리하자. 기존에는 이렇게~ 되어잇었는데 이렇게~ 바꿨다. 오늘 바로 정리할것
                // CHECK: - 2만개가 넘는 데이터를 받고있었다.
                // TODO: - 시이펄~ 2만개가 넘는걸 가져오니까 느리지 쿼리에서 몇개 가져올건지 정하자. 정렬도 거기서하고
                completion(FetchResult.success(searchResult))
            case .failure(let error):
                print(error)
                completion(FetchResult.failure(error))
            }
        }
    }
    
//    static func symbolUrl(_ exchange: String = "US") -> URL? {
//        var c = baseUrlComponents
//        c.path = Endpoint.symbol.path
//
//        let exchangeQi = URLQueryItem(name: "exchange", value: exchange)
//        c.queryItems = [ exchangeQi,tokenQueryItem ]
//
//        let u = c.url
//        return u
//    }
    
//        static func getSearchResults(_ query: String, completion: @escaping ([StockNetworkModel.Symbol]?) -> Void) {
//            let url = symbolUrl()
//            url?.get { (results: [StockNetworkModel.Symbol]?) in
//                let lower = query.lowercased()
//                let filtered = results?.compactMap { $0 }.filter { $0.description.lowercased().contains(lower) || $0.symbol.lowercased().contains(lower) }
//                completion(filtered)
//            }
//        }
}

private extension StockNetworkManager {
    func getFetchedData<T: Codable>(for symbols: [String], completion: @escaping ([(String, FetchResult<T>)]) -> Void) {
        var results = [(String, FetchResult<T>)]()
        // TODO: - 좀더 여기에 알맞는 네이밍 고려해보기
        let dispatchGroup = DispatchGroup()
        
        symbols.forEach {[weak self] symbol in
            guard let url = StockNetworkModel.quoteUrl(symbol) else {
                results.append((symbol, FetchResult.failure(NetworkError.url)))
                return
            }
            
            dispatchGroup.enter()
            
            self?.downloadData(from: url) { (result: FetchResult<T>) in
                results.append((symbol, result))
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(results)
        }
    }
    
    func getFetchedDetailResult(for symbol: String, completion: @escaping (FetchResult<DetailStockModel>) -> Void) {
        var detailStock = DetailStockModel()
        let dispatchGroup = DispatchGroup()
        
        // TODO: - 이 부분 공통화가 가능한지..?
        // TODO: 배열 처리도 해줘야한다.
        
        dispatchGroup.enter()
        downloadStockDetail(from: StockNetworkModel.profile2Url(symbol), dataType: StockNetworkModel.Profile.self) { profile in
            detailStock.profile = profile
            // TODO: - logo Image 받아와야한다.
            if let logoUrlString = profile?.logo, let logoUrl = URL(string: logoUrlString) {
            }
            dispatchGroup.leave()
        }
        
        // download news
        if let newsUrl = StockNetworkModel.newsUrl(symbol) {
            dispatchGroup.enter()
            
            downloadData(from: newsUrl) { (result: FetchResult<[StockNetworkModel.News]>) in
                switch result {
                case .success(let news):
                    // TODO: - 여러개를 받으면 오류가 날 것이다 . 이를 해결하자.
                    detailStock.news = news
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
        
        if let dividendUrl = StockNetworkModel.dividendUrl(symbol) {
            dispatchGroup.enter()
            
            downloadData(from: dividendUrl) { (result: FetchResult<[StockNetworkModel.Dividend]>) in
                switch result {
                case .success(let dividend):
                    // TODO: - 여러개를 받으면 오류가 날 것이다 . 이를 해결하자.
                    detailStock.dividend = dividend
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
        
        if let executeiveUrl = StockNetworkModel.executiveUrl(symbol) {
            dispatchGroup.enter()
            
            downloadData(from: executeiveUrl) { (result: FetchResult<StockNetworkModel.ExecutiveResponse>) in
                switch result {
                case .success(let excutiveResponse):
                    // TODO: - 여러개를 받으면 오류가 날 것이다 . 이를 해결하자.
                    detailStock.excutive = excutiveResponse.executive
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(FetchResult.success(detailStock))
        }
    }
    
    func downloadStockDetail<T: Codable>(from url: URL?, dataType: T.Type,completion: @escaping (T?) -> ()) {
        downloadData(from: url) { (result: FetchResult<T>) in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func downloadData<T: Codable>(from url: URL?, completion: @escaping (FetchResult<T>) -> Void) {
        guard let url = url else {
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
    
    func parseJson<T: Codable>(for data: Data) -> T? {
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
