//
//  StockDetailCoordinator.swift
//  stocks
//
//  Created by 이상범 on 2021/01/25.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

class StockDetailCoordinator: Coordinator {
    var parantCoordinator: Coordinator?
    var childCoordinators: [Coordinator]?
    var navigationVC: UINavigationController?
    var stockItem: StockItem?
    
    init(navigationVC: UINavigationController?) {
        self.navigationVC = navigationVC
    }
    
    func start() {
        let stockDetailVC = StockDetailViewController()
        stockDetailVC.coordinator = self
        stockDetailVC.item = stockItem
        stockDetailVC.provider = .finnhub
       
        stockDetailVC.modalPresentationStyle = .formSheet
        
        // TODO: - Data는 잘 받아오는데 뿌려주는 것에서 지금 아직 UI 작업이 안되어있다.
        navigationVC?.pushViewController(stockDetailVC, animated: true)
    }
    
}
