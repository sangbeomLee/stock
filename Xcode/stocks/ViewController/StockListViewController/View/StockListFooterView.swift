//
//  StockListFooterView.swift
//  stocks
//
//  Created by 이상범 on 2021/01/24.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

final class StockListFooterView: UIView {
    private var relativeDateFormatter = RelativeDateTimeFormatter()
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d h:mm a"
        
        return formatter
    }()
    
    var updatedInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    var date: Data?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupLayout()
    }
    
}

private extension StockListFooterView {
    func setupLayout() {
        addSubview(updatedInfoLabel)
        
        NSLayoutConstraint.activate([
            updatedInfoLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            updatedInfoLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
