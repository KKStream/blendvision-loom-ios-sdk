//
//  UINavigation+Extensions.swift
//  BVPlayerSDKSample
//
//  Created by chantil on 2021/3/15.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit

extension UINavigationController {
    convenience init(rootViewController: UIViewController, title: String? = nil, tabBarItemImage: UIImage? = nil) {
        self.init(rootViewController: rootViewController)

        if let title = title {
            rootViewController.title = title
        }
        if let tabBarItemImage = tabBarItemImage {
            rootViewController.tabBarItem.image = tabBarItemImage
        }
    }
}
