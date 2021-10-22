//
//  BarItemActionHandler.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/9/2.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit
import BlendVisionLoomPlayer

class BarItemActionHandler {
    weak var player: LoomPlayer?

    @objc func didTapHandle() {
        guard let player = player else { return }
        let debugViewController = PlayerToolViewController(player: player)
        let navigationController = UINavigationController(rootViewController: debugViewController)
        navigationController.view.alpha = 0.7
        navigationController.modalPresentationStyle = .formSheet
        UIViewController.topMost?.present(navigationController, animated: true, completion: nil)
    }
}
