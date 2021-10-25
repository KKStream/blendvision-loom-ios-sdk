//
//  UILabel+Copyable.swift
//  BVPlayerSDKSample
//
//  Created by chantil on 2021/4/21.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit

extension UILabel {
    open override var canBecomeFirstResponder: Bool { true }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        action == #selector(UIResponderStandardEditActions.copy(_:))
    }

    open override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text

        if UIMenuController.shared.isMenuVisible {
            UIMenuController.shared.setMenuVisible(false, animated: true)
        }
    }
}
