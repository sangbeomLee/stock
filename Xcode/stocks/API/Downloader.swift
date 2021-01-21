//
//  Downloader.swift
//  stocks
//
//  Created by 이상범 on 2021/01/21.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

enum DownloaderError: Error {
    case dataError
    case responseError
    case fetchError
}

public class Downloader {
    typealias DownloadedDataResult = Result<Data, Error>
    
    static var shared = Downloader()
    
    private let session: URLSession
    
    init (session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func downloadData(from url: URL, completion: @escaping (DownloadedDataResult) -> ()) {
        self.session.dataTask(with: url) { (data, response, error) in
            guard error == nil else{
                completion(DownloadedDataResult.failure(DownloaderError.fetchError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                completion(DownloadedDataResult.failure(DownloaderError.responseError))
                return
            }
            
            guard let data = data else {
                completion(DownloadedDataResult.failure(DownloaderError.dataError))
                return
            }
            
            completion(DownloadedDataResult.success(data))
        }.resume()
    }
}
