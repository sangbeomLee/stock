//
//  StockListCoordinator.swift
//  stocks
//
//  Created by 이상범 on 2021/01/23.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

class StockListCoordinator: Coordinator {
    weak var parantCoordinator: Coordinator?
    var childCoordinators: [Coordinator]
    var navigationVC: UINavigationController?
    
    init(parantCoordinator: Coordinator, navigationVC: UINavigationController?) {
        self.parantCoordinator = parantCoordinator
        self.navigationVC = navigationVC
        childCoordinators = [Coordinator]()
    }
    
    func start() {
        guard let stockListVC = StockListViewController.instantiatingFromNib() else {
            // TODO: - Error 처리
            print("error: App Coordinator")
            return
        }
        
        navigationVC?.pushViewController(stockListVC, animated: true)
    }
}

