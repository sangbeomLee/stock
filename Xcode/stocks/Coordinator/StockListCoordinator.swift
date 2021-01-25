//
//  StockListCoordinator.swift
//  stocks
//
//  Created by 이상범 on 2021/01/23.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

class StockListCoordinator: NSObject, Coordinator {
    weak var parantCoordinator: Coordinator?
    var childCoordinators: [Coordinator]?
    var navigationVC: UINavigationController?
    
    init(navigationVC: UINavigationController?) {
        self.navigationVC = navigationVC
        childCoordinators = [Coordinator]()
    }
 
    func start() {
        navigationVC?.delegate = self
        guard let stockListVC = StockListViewController.instantiatingFromNib() else {
            // TODO: - Error 처리
            print("error: App Coordinator")
            return
        }
        stockListVC.coordinator = self
        
        navigationVC?.pushViewController(stockListVC, animated: true)
    }
    
    func createAddStockViewController() {
        // TODO: - present로 할 것이기 때문에 새로운 navigationVC 를 넣어 주었다. 이 부분을 해결하는 것을 고민해보자.
        let child = AddStockCoordinator(navigationVC: UINavigationController())
        child.parantCoordinator = self
        
        child.start()
        childCoordinators?.append(child)
    }
    
    func createStockDetailViewController(_ item: StockItem) {
        let child = StockDetailCoordinator(navigationVC: navigationVC)
        child.parantCoordinator = self
        child.stockItem = item
        
        child.start()
        childCoordinators?.append(child)
    }
}

// TODO: - 이 부분을 UINavigationControllerDelegate 를 받은 것을 Coordinate 로 상속하고 protocol 을 CoordinatorType 으로 변경 해보자.
extension StockListCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.contains(fromViewController) {
            return
        }
        
        if let stockDetailViewController = fromViewController as? StockDetailViewController {
            childDidFinish(stockDetailViewController.coordinator)
        }
    }
}
