//
//  UIView+Extension.swift
//  stocks
//
//  Created by 이상범 on 2021/01/23.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

extension UIView {
    func loadView(nibName: String) -> UIView? {
        //Get all views in the xib
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
