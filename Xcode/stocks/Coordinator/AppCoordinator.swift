//
//  AppCoordinator.swift
//  stocks
//
//  Created by 이상범 on 2021/01/23.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    var parantCoordinator: Coordinator? = nil
    var childCoordinators: [Coordinator]? = [Coordinator]()
    var navigationVC: UINavigationController? = UINavigationController()
    
    func start() {
        let childCoordinator = StockListCoordinator(navigationVC: navigationVC)
        childCoordinator.parantCoordinator = self
        childCoordinators?.append(childCoordinator)
        childCoordinator.start()
    }
}
