//
//  AlertPresentable.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/8/19.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit

protocol AlertPresentable {
    func presentAlert(_ alert: UIAlertController, animated: Bool, completion: (() -> Void)?)
}

extension UIViewController: AlertPresentable {}

extension AlertPresentable where Self: UIViewController {
    func sourceView() -> UIView? { view }

    func sourceRect() -> CGRect { view.bounds }

    func permittedArrowDirections() -> UIPopoverArrowDirection { [] }

    func presentAlert(_ alert: UIAlertController, animated: Bool, completion: (() -> Void)? = nil) {
        if alert.preferredStyle == .actionSheet, let popover = alert.popoverPresentationController {
            popover.sourceView = sourceView()
            popover.sourceRect = sourceRect()
            popover.permittedArrowDirections = permittedArrowDirections()
        }
        present(alert, animated: animated, completion: completion)
    }
}
