//
//  ViewHierarchy.swift
//  BVPlayerSDK
//
//  Created by chantil on 2021/2/25.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit

extension UIWindow {
    static func findKeyWindow() -> UIWindow? {
        if let window = UIApplication.shared.keyWindow, window.windowLevel == .normal {
            // A key window of main app exists, go ahead and use it
            return window
        }

        // Otherwise, try to find a normal level window
        let window = UIApplication.shared.windows.first { $0.windowLevel == .normal }
        guard let result = window else {
            print("Cannot find a valid UIWindow at normal level. Current windows: \(UIApplication.shared.windows)")
            return nil
        }
        return result
    }
}

extension UIViewController {
    static var topMost: UIViewController? {
        let keyWindow = UIWindow.findKeyWindow()
        if let window = keyWindow, !window.isKeyWindow {
            print("Cannot find a key window. Making window \(window) to keyWindow. " +
                    "This might be not what you want, please check your window hierarchy.")
            window.makeKey()
        }
        guard var topViewController = keyWindow?.rootViewController else {
            print("Cannot find a root view controller in current window. " +
                    "Please check your view controller hierarchy.")
            return nil
        }

        while let currentTop = topViewController.presentedViewController {
            topViewController = currentTop
        }

        return topViewController
    }
}
