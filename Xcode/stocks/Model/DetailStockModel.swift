//
//  DetailStockModel.swift
//  stocks
//
//  Created by 이상범 on 2021/01/22.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

struct DetailStockModel {
    var profile: StockNetworkModel.Profile? = nil
    var news: [StockNetworkModel.News]? = nil
    var dividend: [StockNetworkModel.Dividend]? = nil
    var image: UIImage? = nil
    var excutive: [StockNetworkModel.Executive]? = nil
}
