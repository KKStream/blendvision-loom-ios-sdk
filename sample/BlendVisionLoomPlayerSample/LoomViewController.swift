//
//  LoomViewController.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/8/26.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit
import BlendVisionLoomPlayer

class LoomViewController: SingleRowSectionTableViewController<LoomViewController.Section> {
}

// MARK: - Section
extension LoomViewController {
    enum Section: SingleRowSection {
        case presentPlayer
        case sizablePlayer
        case version

        var rowTitle: String? {
            switch self {
            case .presentPlayer: return "Present Player"
            case .sizablePlayer: return "Sizable Player"
            case .version: return "Version: \(Configuration.version)"
            }
        }

        var footerTitle: String? {
            switch self {
            case .presentPlayer: return "Use Loom.shared.presentPlayer(...) to present player as a view controller."
            case .sizablePlayer: return "Use LoomPlayer(...) to generate player for sizable player view."
            case .version: return nil
            }
        }

        var rowAccessoryType: UITableViewCell.AccessoryType {
            switch self {
            case .version: return .none
            default: return .disclosureIndicator
            }
        }

        var rowAction: ((UIViewController) -> Void)? {
            switch self {
            case .presentPlayer:
                return { viewController in
                    let controller = UseCaseViewController(.forPresentedSinglePlayer)
                    controller.title = rowTitle
                    viewController.navigationController?.pushViewController(controller, animated: true)
                }
            case .sizablePlayer:
                return { viewController in
                    let controller = UseCaseViewController(.forMultipleSizablePlayers)
                    controller.title = rowTitle
                    viewController.navigationController?.pushViewController(controller, animated: true)
                }
            case .version:
                return nil
            }
        }
    }
}
