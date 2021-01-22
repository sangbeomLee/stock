//
//  DetailStockModel.swift
//  stocks
//
//  Created by 이상범 on 2021/01/22.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

struct DetailStockModel {
    var profile: Finnhub.Profile? = nil
    var news: [Finnhub.News]? = nil
    var dividend: [Finnhub.Dividend]? = nil
    var image: UIImage? = nil
    var excutive: [Finnhub.Executive]? = nil
}
