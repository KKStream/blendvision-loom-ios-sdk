//
//  PageViewController.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/9/10.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit
import BlendVisionLoomPlayer

class PageViewController: UIPageViewController {
    var currentIndex: Int {
        guard let currentController = currentController else { return 0 }
        return controllers.firstIndex(of: currentController) ?? 0
    }
    var currentController: SinglePlayerViewController? {
        viewControllers?.first as? SinglePlayerViewController
    }
    var controllers: [SinglePlayerViewController] = []

    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)

        delegate = self
        dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        if let initialController = controller(at: 0) {
            setViewControllers([initialController], direction: .forward, animated: false, completion: nil)
        }

        // preload initial view controller
        _ = controller(at: 0)?.view

        // preload next view controller or other view controllers
        _ = controller(at: 1)?.view
    }

    func controller(at index: Int) -> SinglePlayerViewController? {
        guard controllers.indices.contains(index) else { return nil }
        return controllers[index]
    }
}

// MARK: - UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        _ = pendingViewControllers[0].view
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // pause previous player
            (previousViewControllers[0] as? SinglePlayerViewController)?.player.pause()

            // play current player
            currentController?.player.play()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        controller(at: currentIndex - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        controller(at: currentIndex + 1)
    }
}

// MARK: - PlayerEventHandling
extension PageViewController: PlayerEventHandling {
    func didEndVideo(_ player: LoomPlayer, at index: Int) {
        player.seek(to: 0)
    }

    func didLoad(_ player: LoomPlayer) {
        // disable auto-play when player loaded successfully out of screen
        if player !== (viewControllers?[0] as? SinglePlayerViewController)?.player {
            player.pause()
        }
    }

    func didReceiveVideoEvent(_ player: LoomPlayer?, videoEvent: VideoEvent) {
        // handle video events
        // ...
    }
}
