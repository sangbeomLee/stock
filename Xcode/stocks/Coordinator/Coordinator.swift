//
//  Coordinator.swift
//  stocks
//
//  Created by 이상범 on 2021/01/23.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

// TODO: - Error 처리에 대한 부분
protocol Coordinator: AnyObject {
    var parantCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigationVC: UINavigationController? { get set }
    
    func start()
}
