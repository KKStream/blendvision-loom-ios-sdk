//
//  UseCaseViewController.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/9/2.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit
import BlendVisionLoomPlayer

class UseCaseViewController: UITableViewController {
    enum UseCase {
        case forPresentedSinglePlayer
        case forMultipleSizablePlayers
    }

    enum Section: CaseIterable {
        case player
        case demo
        case showcase

        var title: String? {
            switch self {
            case .player: return "Player"
            case .demo: return "Demo"
            case .showcase: return "Showcase"
            }
        }
    }

    enum Row: String {
        case player
        case addPlayer
        case presentSinglePlayer
        case displayMultipleSizedPlayers
        case displayMultiplePlayersInPages

        var title: String? {
            switch self {
            // player
            case .player: return "Player"
            case .addPlayer: return "＋ Add Player"

            // demo
            case .presentSinglePlayer: return "Present Single Player Modally"

            // showcase
            case .displayMultipleSizedPlayers: return "Display Multiple-Sized Players"
            case .displayMultiplePlayersInPages: return "Embed Players in UIPageViewController"
            }
        }

        var detail: String? {
            switch self {
            case .player, .addPlayer: return nil
            case .presentSinglePlayer: return """

                ▪︎ single player presented modally
                ▪︎ fullscreen/auto-rotation not supported
                ▪︎ player events not handled (using default behaviors)
                """
            case .displayMultipleSizedPlayers: return """

                ▪︎ multiple-sized players in one view controller
                ▪︎ player's height grows with index
                ▪︎ player events not handled (using default behaviors)
                """
            case .displayMultiplePlayersInPages: return """

                ▪︎ multiple same-sized players in separate view controller
                ▪︎ one player per page (horizontal swipe to prev/next page)
                ▪︎ preload off-screen players
                ▪︎ player events handled:
                    ▪︎ didLoad: auto-pause off-screen players
                    ▪︎ didEndVideo: auto-replay (`seek(to: 0)`) when video ends
                    ▪︎ didFail: not handled (using default behaviors)
                """
            }
        }

        var accessoryType: UITableViewCell.AccessoryType {
            switch self {
            case .player, .addPlayer:
                return .none
            case .presentSinglePlayer, .displayMultipleSizedPlayers, .displayMultiplePlayersInPages:
                return .disclosureIndicator
            }
        }
    }

    let cellIdentifier = "CellIdentifier"
    let useCase: UseCase
    let sections: [Section]
    private(set) var models: [LoomPlayerModel] = []
    private(set) var barItemEventHandlers: [BarItemActionHandler?] = []

    init(_ useCase: UseCase) {
        self.useCase = useCase
        self.sections = {
            switch useCase {
            case .forPresentedSinglePlayer:
                return [.player, .demo]
            case .forMultipleSizablePlayers:
                return [.player, .demo, .showcase]
            }
        }()

        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows(in: sections[section]).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        let cell = dequeuedCell ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)

        let row = rows(in: sections[indexPath.section])[indexPath.row]
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = row.detail
        cell.accessoryType = row.accessoryType
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = rows(in: sections[indexPath.section])[indexPath.row]
        switch row {
        case .player:
            let controller = EditPlayerViewController(model: models[indexPath.row])
            controller.didUpdatePlayerModelHandler = { [weak self] model in
                self?.models[indexPath.row] = model
                self?.barItemEventHandlers[indexPath.row] = controller.barItemEventHandler
                self?.tableView.reloadData()
                self?.dismiss(animated: true, completion: nil)
            }
            let navigationController = UINavigationController(rootViewController: controller)
            present(navigationController, animated: true, completion: nil)
        case .addPlayer:
            let controller = EditPlayerViewController()
            controller.didUpdatePlayerModelHandler = { [weak self] model in
                self?.models.append(model)
                self?.barItemEventHandlers.append(controller.barItemEventHandler)
                self?.tableView.reloadData()
                self?.dismiss(animated: true, completion: nil)
            }
            let navigationController = UINavigationController(rootViewController: controller)
            present(navigationController, animated: true, completion: nil)
        case .presentSinglePlayer:
            guard let model = models.first else { return }
            Loom.shared.presentPlayer(context: PlayerContext(barItems: model.context.barItems),
                                      contents: model.contents,
                                      startIndex: model.startIndex,
                                      eventHandler: nil,
                                      completion: { player in
                                        self.barItemEventHandlers.first??.player = player
                                      })
        case .displayMultipleSizedPlayers:
            var players = [LoomPlayer]()
            for (index, model) in models.enumerated() {
                let player = LoomPlayer(context: model.context,
                                        contents: model.contents,
                                        startIndex: model.startIndex,
                                        eventHandler: nil)
                barItemEventHandlers[index]?.player = player
                players.append(player)
            }
            let controller = MultiplePlayerViewController(players: players)
            navigationController?.pushViewController(controller, animated: true)
        case .displayMultiplePlayersInPages:
            let pager = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

            var players = [LoomPlayer]()
            var controllers = [SinglePlayerViewController]()
            for (index, model) in models.enumerated() {
                let player = LoomPlayer(context: model.context,
                                        contents: model.contents,
                                        startIndex: model.startIndex,
                                        eventHandler: pager)
                barItemEventHandlers[index]?.player = player
                players.append(player)
                controllers.append(SinglePlayerViewController(player: player))
            }
            pager.controllers = controllers
            navigationController?.pushViewController(pager, animated: true)
        }
    }

    func rows(in section: Section) -> [Row] {
        switch (useCase, section) {
        case (.forPresentedSinglePlayer, .player):
            return models.isEmpty ? [.addPlayer] : [.player]
        case (.forPresentedSinglePlayer, .demo):
            return [.presentSinglePlayer]
        case (.forPresentedSinglePlayer, .showcase):
            return []

        case (.forMultipleSizablePlayers, .player):
            return Array(repeating: .player, count: models.count) + [.addPlayer]
        case (.forMultipleSizablePlayers, .demo):
            return [.displayMultipleSizedPlayers]
        case (.forMultipleSizablePlayers, .showcase):
            return [.displayMultiplePlayersInPages]
        }
    }
}
