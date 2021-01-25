//
//  AddStockCoordinator.swift
//  stocks
//
//  Created by 이상범 on 2021/01/25.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

protocol AddStockCoordinatorDelegate: AnyObject {
    func viewContollerDidEnd(_ coordinator: Coordinator)
}

class AddStockCoordinator: Coordinator {
    weak var parantCoordinator: Coordinator?
    weak var delegate: AddStockCoordinatorDelegate?
    var childCoordinators: [Coordinator]?
    var navigationVC: UINavigationController?
    
    init(navigationVC: UINavigationController?) {
        self.navigationVC = navigationVC
        childCoordinators = [Coordinator]()
    }

    func start() {
        guard let navigationVC = navigationVC else { return }
        let addStockVC = AddStockViewController()
        addStockVC.coordinator = self
        
        addStockVC.modalPresentationStyle = .formSheet
        navigationVC.viewControllers.append(addStockVC)
        
        // TODO: - 이보다 좋은 방법이 있는지 고민하기.
        parantCoordinator?.navigationVC?.present(navigationVC, animated: true)
    }
    
    func end() {
        delegate?.viewContollerDidEnd(self)
    }
}
