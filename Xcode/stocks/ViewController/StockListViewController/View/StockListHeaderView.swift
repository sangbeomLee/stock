//
//  StockListHeaderView.swift
//  stocks
//
//  Created by 이상범 on 2021/01/25.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

final class StockListHeaderView: UIView {
    let sortButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Theme.color
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        button.layer.cornerRadius = 13
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        return button
    }()
    
    var sortButtonTitle: String? {
        get {
            sortButton.currentTitle
        }
        
        set {
            sortButton.setTitle(newValue, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private extension StockListHeaderView {
    func setup() {
        addSubview(sortButton)
        setupLayout()
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            sortButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sortButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
        ])
    }
}
